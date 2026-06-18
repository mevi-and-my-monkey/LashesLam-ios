//
//  CatalogNotifications.swift
//  LashesLam
//
//  Notificación para refrescar catálogos tras cambios del administrador
//  (crear/editar/eliminar productos, cursos o servicios).
//

import Foundation

extension Notification.Name {
    static let catalogDidChange = Notification.Name("catalogDidChange")
}
