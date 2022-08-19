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
    let colors1:[UIColor] = [.green, .cyan, .blue]
    let colors2:[UIColor] = [.blue, .purple, .systemPink, .red]

    var body: some View {
        ZStack{
            Rectangle()
                .animatableGradient(from: colors1, to: colors2, progress: progress)
                .mask {
                    Text("Leitner Box".uppercased())
                        .font(.system(size: 52, weight: .heavy, design: .rounded ))
                        .opacity(hideSplash ? 0.0 : 1)
                        .scaleEffect(x: hideSplash ? 10 : 1, y: hideSplash ? 10 : 1, anchor: .center)
                        .rotation3DEffect(.degrees(animateGradient ? 45 : 0), axis: (x: 0, y: 1, z: 0))
                        .animation(.interpolatingSpring(stiffness: 1, damping: 1).speed(3), value: hideSplash)
                }

            VStack{
                Spacer()
                HStack(spacing: 4){
                    Text("Powered by")
                        .font(.footnote)
                    Image(systemName: "swift")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .foregroundColor(.orange)
                }
                .scaleEffect(x: animateGradient ? 1 : 0.7, y: animateGradient ? 1 : 0.7, anchor: .center)
                .opacity(hideSplash ? 0 : 1)
                .animation(.easeInOut, value: hideSplash)

            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0)) {
                animateGradient = true
                progress = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.5)) {
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
