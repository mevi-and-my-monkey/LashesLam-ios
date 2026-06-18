//
//  Array+Chunked.swift
//  LashesLam
//
//  Divide un arreglo en lotes de 10 (Firestore limita whereIn a 10 elementos).
//

import Foundation

extension Array {
    func chunkedInTens() -> [[Element]] {
        guard count > 10 else { return isEmpty ? [] : [self] }
        return stride(from: 0, to: count, by: 10).map {
            Array(self[$0..<Swift.min($0 + 10, count)])
        }
    }
}
