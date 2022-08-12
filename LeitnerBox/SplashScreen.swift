//
//  SplashScreen.swift
//  LeitnerBox
//
//  Created by hamed on 8/11/22.
//

import Foundation
import SwiftUI

struct SplashScreen: View {

    @State
    var animateGradient = false

    @State
    var hideSplash = false

    @State private var progress: CGFloat = 0
    let colors1:[UIColor] = [.orange, .red , .systemIndigo]
    let colors2:[UIColor] = [.yellow, .brown, .orange]

    var body: some View {
        ZStack{
            LinearGradient(colors: [.green, .cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                .hueRotation(.degrees(hideSplash ? 45 : 0))
                .ignoresSafeArea()
            Rectangle()
                .animatableGradient(from: colors1, to: colors2, progress: progress)
                .mask {
                    Text("Leitner Box".uppercased())
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .opacity(hideSplash ? 0.0 : 1)
                        .scaleEffect(x: hideSplash ? 8 : 1, y: hideSplash ? 8 : 1, anchor: .center)
                        .animation(.easeInOut, value: hideSplash)
                }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 2.0)) {
                animateGradient = true
                progress = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeIn(duration: 0.5)) {
                    hideSplash.toggle()
                }
            }
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .animation(.easeInOut(duration: 3), value: UUID())
            .previewDevice("iPhone 13 Pro Max")
    }
}
