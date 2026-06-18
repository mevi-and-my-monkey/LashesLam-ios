//
//  EditPhoneSheet.swift
//  LashesLam
//
//  Hoja para editar el teléfono (solo dígitos), igual que
//  ui/profile/EditPhoneBottomSheet.kt.
//

import SwiftUI

struct EditPhoneSheet: View {
    @Environment(\.dismiss) var dismiss
    var currentPhone: String?
    var onSave: (String) -> Void

    @State private var phone = ""

    private var isEnabled: Bool { phone.count >= 8 }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                TextField("Número de teléfono", text: $phone)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                    .onChange(of: phone) { newValue in
                        // Solo dígitos, como en Android (filter Char::isDigit).
                        let digits = newValue.filter(\.isNumber)
                        if digits != newValue { phone = digits }
                    }

                PrimaryButton(text: "Guardar") {
                    onSave(phone)
                    dismiss()
                }
                .disabled(!isEnabled)
                .opacity(isEnabled ? 1 : 0.5)

                Spacer()
            }
            .padding()
            .navigationTitle("Editar teléfono")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .onAppear { phone = currentPhone ?? "" }
        }
        .presentationDetents([.medium])
    }
}
