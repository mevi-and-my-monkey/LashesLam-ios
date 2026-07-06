//
//  HomeBannerViewModel.swift
//  LashesLam
//
//  Carga/administra los banners del Home (data/banners.urls) y resuelve el curso
//  vinculado a un banner (data/curse/items where banner == index), igual que
//  BannerView.kt de Android.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

@MainActor
final class HomeBannerViewModel: ObservableObject {

    @Published var urls: [String] = []
    @Published var isLoading = false
    @Published var message: String?

    private var firestore: Firestore { Firestore.firestore() }
    private var storage: Storage { Storage.storage() }
    private var bannersDoc: DocumentReference { firestore.collection("data").document("banners") }

    func load() {
        Task {
            let snapshot = try? await bannersDoc.getDocument()
            urls = snapshot?.get("urls") as? [String] ?? []
        }
    }

    /// Busca el curso vinculado a la posición `index` del banner.
    func courseId(forBanner index: Int) async -> String? {
        let query = firestore.collection("data").document("curse")
            .collection("items").whereField("banner", isEqualTo: index)
        let snapshot = try? await query.getDocuments()
        return snapshot?.documents.first?.documentID
    }

    func uploadBanner(_ data: Data) {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let ref = storage.reference().child("banners/\(Int(Date().timeIntervalSince1970 * 1000)).jpg")
                _ = try await ref.putDataAsync(data)
                let url = try await ref.downloadURL().absoluteString
                try await bannersDoc.updateData(["urls": FieldValue.arrayUnion([url])])
                urls.append(url)
                message = "Banner subido correctamente"
            } catch {
                message = "Error al subir el banner"
            }
        }
    }

    func deleteBanner(at index: Int) {
        guard urls.indices.contains(index) else { return }
        let url = urls[index]
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let ref = storage.reference(forURL: url)
                try? await ref.delete()
                try await bannersDoc.updateData(["urls": FieldValue.arrayRemove([url])])
                urls.removeAll { $0 == url }
                message = "Banner eliminado correctamente"
            } catch {
                message = "Error al eliminar el banner"
            }
        }
    }
}
