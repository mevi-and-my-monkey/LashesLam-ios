//
//  UserRepository.swift
//  LashesLam
//
//  Espejo de data/UserRepositoryImpl.kt. Autenticación + persistencia del usuario
//  en Firestore, contra el mismo backend que Android.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import GoogleSignIn
import FirebaseCore

final class UserRepository {

    private var auth: Auth { Auth.auth() }
    private var firestore: Firestore { Firestore.firestore() }
    private var storage: Storage { Storage.storage() }

    // MARK: - Email / password

    func signIn(email: String, password: String) async -> Resource<Bool> {
        do {
            try await auth.signIn(withEmail: email, password: password)
            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func register(_ user: UserModel) async -> Resource<Bool> {
        do {
            let result = try await auth.createUser(
                withEmail: user.email ?? "",
                password: user.password ?? ""
            )
            let userId = result.user.uid

            // Se guarda como UserDto para no persistir password.
            let dto = user.toDto()
            var data = dto.toFirestoreData()
            data["uid"] = userId

            try await firestore
                .document(FirestorePaths.Users.document(userId))
                .setData(data, merge: true)

            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    // MARK: - Google Sign-In

    @MainActor
    func signInWithGoogle(presenting viewController: UIViewController) async -> Resource<Bool> {
        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                return .failure(.unknown("Falta clientID de Firebase"))
            }
            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: viewController)
            let gUser = signInResult.user
            guard let idToken = gUser.idToken?.tokenString else {
                return .failure(.unknown("No se obtuvo el token de Google"))
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: gUser.accessToken.tokenString
            )

            let authResult = try await auth.signIn(with: credential)
            let firebaseUser = authResult.user
            let userId = firebaseUser.uid

            let userDoc = firestore.document(FirestorePaths.Users.document(userId))
            let snapshot = try await userDoc.getDocument()

            if !snapshot.exists {
                let dto = UserDto(
                    name: firebaseUser.displayName,
                    email: firebaseUser.email,
                    uid: userId,
                    phone: firebaseUser.phoneNumber,
                    address: "",
                    userPhoto: firebaseUser.photoURL?.absoluteString,
                    photoUpdatedByUser: false
                )
                try await userDoc.setData(dto.toFirestoreData(), merge: true)
            } else {
                // Usuario existente: solo se mergea identidad, no address/phone.
                var identity: [String: Any] = [:]
                if let name = firebaseUser.displayName { identity[FirestorePaths.Users.userName] = name }
                if let email = firebaseUser.email { identity["email"] = email }
                identity["uid"] = userId
                try await userDoc.setData(identity, merge: true)
            }

            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    // MARK: - Sign in with Apple

    /// Inicia sesión en Firebase con la credencial de Apple. Crea/mergea users/{uid}
    /// igual que el flujo de Google. fullName solo llega en el primer inicio.
    func signInWithApple(idToken: String, rawNonce: String, fullName: String?) async -> Resource<Bool> {
        do {
            let credential = OAuthProvider.appleCredential(
                withIDToken: idToken,
                rawNonce: rawNonce,
                fullName: nil
            )
            let authResult = try await auth.signIn(with: credential)
            let firebaseUser = authResult.user
            let userId = firebaseUser.uid

            let userDoc = firestore.document(FirestorePaths.Users.document(userId))
            let snapshot = try await userDoc.getDocument()

            if !snapshot.exists {
                let dto = UserDto(
                    name: fullName ?? firebaseUser.displayName,
                    email: firebaseUser.email,
                    uid: userId,
                    phone: firebaseUser.phoneNumber,
                    address: "",
                    userPhoto: firebaseUser.photoURL?.absoluteString,
                    photoUpdatedByUser: false
                )
                try await userDoc.setData(dto.toFirestoreData(), merge: true)
            } else {
                var identity: [String: Any] = [:]
                let name = fullName ?? firebaseUser.displayName
                if let name, !name.isEmpty { identity[FirestorePaths.Users.userName] = name }
                if let email = firebaseUser.email { identity["email"] = email }
                identity["uid"] = userId
                try await userDoc.setData(identity, merge: true)
            }
            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    // MARK: - Foto de perfil

    func updateProfilePhoto(data imageData: Data) async -> Resource<String> {
        do {
            guard let userId = auth.currentUser?.uid else {
                return .failure(.unknown(nil))
            }
            let ref = storage.reference().child(StoragePaths.Users.profilePhoto(userId))
            _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL().absoluteString

            try await firestore
                .document(FirestorePaths.Users.document(userId))
                .setData([
                    FirestorePaths.Users.userPhoto: url,
                    FirestorePaths.Users.photoUpdatedByUser: true
                ], merge: true)

            return .success(url)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    // MARK: - Lectura / edición de datos del usuario

    /// Lee el documento users/{uid}. Espejo de ProfileViewModel.loadUserData (Android).
    func fetchUser() async -> UserModel? {
        guard let userId = auth.currentUser?.uid else { return nil }
        guard let snapshot = try? await firestore
            .document(FirestorePaths.Users.document(userId)).getDocument(),
            let data = snapshot.data() else { return nil }

        return UserModel(
            name: data["name"] as? String,
            email: data["email"] as? String,
            uid: data["uid"] as? String ?? userId,
            phone: data["phone"] as? String,
            address: data["address"] as? String,
            userPhoto: data["userPhoto"] as? String,
            photoUpdatedByUser: (data["photoUpdatedByUser"] as? Bool) ?? false
        )
    }

    func updateAddress(_ address: String) async -> Resource<Bool> {
        guard let userId = auth.currentUser?.uid else { return .failure(.unknown(nil)) }
        guard !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.unknown("La dirección no puede estar vacía"))
        }
        do {
            try await firestore.document(FirestorePaths.Users.document(userId))
                .updateData(["address": address])
            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }

    func updatePhone(_ phone: String) async -> Resource<Bool> {
        guard let userId = auth.currentUser?.uid else { return .failure(.unknown(nil)) }
        do {
            try await firestore.document(FirestorePaths.Users.document(userId))
                .updateData(["phone": phone])
            return .success(true)
        } catch {
            return .failure(ErrorMapper.map(error))
        }
    }
}
