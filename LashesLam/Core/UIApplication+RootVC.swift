//
//  UIApplication+RootVC.swift
//  LashesLam
//
//  Helper para obtener el view controller visible (necesario para presentar
//  el flujo de Google Sign-In).
//

import UIKit

extension UIApplication {
    var topViewController: UIViewController? {
        let scene = connectedScenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
        let root = scene?.windows.first { $0.isKeyWindow }?.rootViewController
        var top = root
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }
}
