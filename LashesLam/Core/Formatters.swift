//
//  Formatters.swift
//  LashesLam
//
//  Helpers de formato. Espejo de utils/Utilities.kt (formatMoney + WhatsApp).
//

import Foundation

enum Formatters {
    /// Formatea dinero: "$1234" si es entero, "$1234.56" si tiene decimales.
    static func money(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1.0) == 0.0 {
            return "$\(Int(value))"
        }
        return "$" + String(format: "%.2f", value)
    }

    /// URL de WhatsApp con mensaje de interés en un producto (igual que Android).
    static func whatsAppProductURL(title: String, price: String, whatsapp: String) -> URL? {
        let message = """
        Hola, me gustaría recibir más información sobre el producto \(title).
        Precio: \(price).
        ¡Gracias!
        """
        let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://wa.me/\(whatsapp)?text=\(encoded)")
    }

    /// Formatea la duración de un servicio (horas/minutos), igual que Android.
    static func serviceDuration(_ duration: Double) -> String {
        let hours = Int(duration)
        let minutes = Int((duration - Double(hours)) * 60)
        if hours > 0 && minutes > 0 { return "\(hours) h \(minutes)" }
        if hours > 0 { return "\(hours) h" }
        return "\(minutes) min"
    }

    /// URL de WhatsApp con el detalle de una reserva de cita.
    static func whatsAppReservationURL(reservation: ServiceReservation, whatsapp: String) -> URL? {
        let message = """
        Hola, soy \(reservation.nameUser) y quiero reservar una cita:
        Reserva: #\(reservation.reservationNumber)

        Servicio: \(reservation.serviceName)
        Fecha: \(reservation.dateLabel)
        Hora: \(reservation.time)
        Duración: \(reservation.durationLabel)
        Total: \(money(reservation.price))

        Quedo al pendiente de los datos para el anticipo. ¡Gracias!
        """
        let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://wa.me/\(whatsapp)?text=\(encoded)")
    }

    /// URL de WhatsApp con el detalle de una orden (igual que createOrderMessageWhatsApp).
    static func whatsAppOrderURL(order: ProductOrder, whatsapp: String) -> URL? {
        let itemsDetail = order.items.map {
            "• \($0.quantity) x \($0.title) — \(money($0.price * Double($0.quantity)))"
        }.joined(separator: "\n")

        let shippingLine = order.shipping > 0 ? "\nEnvío: \(money(order.shipping))" : ""

        let message = """
        Hola, soy \(order.nameUser) y quiero realizar el siguiente pedido:
        Orden: #\(order.orderNumber)

        \(itemsDetail)

        Subtotal: \(money(order.subtotal))\(shippingLine)
        Total: \(money(order.total))

        ¡Gracias!
        """
        let encoded = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://wa.me/\(whatsapp)?text=\(encoded)")
    }
}
