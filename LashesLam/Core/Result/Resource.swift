//
//  Resource.swift
//  LashesLam
//
//  Espejo de core/results/Resource.kt: envuelve el resultado de una operación.
//

import Foundation

enum Resource<T> {
    case success(T)
    case failure(AppError)
}
