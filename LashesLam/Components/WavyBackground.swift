//
//  WavyBackground.swift
//  LashesLam
//
//  Created by Alejandro Mejia v on 18/10/25.
//

import Foundation
import SwiftUI

struct WavyBackground<Content: View>: View {
    var backgroundColor: Color = AppColors.background
    var bigWaveColor: Color = AppColors.surface
    var smallWaveColor: Color = AppColors.surfaceVariant
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                backgroundColor
                    .ignoresSafeArea()
                
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    path.move(to: CGPoint(x: 0, y: h * 0.28))
                    path.addQuadCurve(to: CGPoint(x: w, y: h * 0.28), control: CGPoint(x: w/2, y: h * 0.43))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()
                }
                .fill(bigWaveColor)
                
                Path { path in
                    let w = geo.size.width
                    let h = geo.size.height
                    path.move(to: CGPoint(x: 0, y: h * 0.3))
                    path.addQuadCurve(to: CGPoint(x: w, y: h * 0.3), control: CGPoint(x: w/2, y: h * 0.45))
                    path.addLine(to: CGPoint(x: w, y: h))
                    path.addLine(to: CGPoint(x: 0, y: h))
                    path.closeSubpath()
                }
                .fill(smallWaveColor)
                
                content()
                    .padding(.horizontal, 32)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}
