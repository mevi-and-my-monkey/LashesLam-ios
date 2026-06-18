//
//  EditAddressSheet.swift
//  LashesLam
//
//  Hoja para editar la dirección con campos estructurados, igual que
//  ui/profile/EditAddressBottomSheet.kt. Compone un único string de dirección.
//

import SwiftUI

struct EditAddressSheet: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (String) -> Void

    @State private var street = ""
    @State private var extNumber = ""
    @State private var intNumber = ""
    @State private var suburb = ""
    @State private var city = ""
    @State private var postalCode = ""

    private var isEnabled: Bool {
        !street.isEmpty && !extNumber.isEmpty && !suburb.isEmpty && !city.isEmpty && !postalCode.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    field("Calle", text: $street)
                    field("Número exterior", text: $extNumber, keyboard: .numbersAndPunctuation)
                    field("Número interior (opcional)", text: $intNumber)
                    field("Colonia", text: $suburb)
                    field("Ciudad", text: $city)
                    field("Código postal", text: $postalCode, keyboard: .numberPad)

                    PrimaryButton(text: "Guardar") {
                        var full = "\(street) #\(extNumber)"
                        if !intNumber.trimmingCharacters(in: .whitespaces).isEmpty {
                            full += ", Int. \(intNumber)"
                        }
                        full += ", \(suburb), \(city), CP \(postalCode)"
                        onSave(full)
                        dismiss()
                    }
                    .disabled(!isEnabled)
                    .opacity(isEnabled ? 1 : 0.5)
                }
                .padding()
            }
            .navigationTitle("Editar dirección")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
        }
        .presentationDetents([.large])
    }

    private func field(_ label: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(label, text: text)
            .textFieldStyle(.roundedBorder)
            .keyboardType(keyboard)
    }
}
