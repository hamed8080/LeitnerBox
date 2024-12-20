//
//  EmptyLeitnerAnimation.swift
//  LeitnerBox
//
//  Created by hamed on 10/10/24.
//

import SwiftUI

struct EmptyLeitnerAnimation: View {
    @EnvironmentObject var viewModel: LeitnerViewModel

    var body: some View {
        if viewModel.leitners.count == 0 {
            ZStack {
                GradientAnimationView()
                ZStack {
                    VStack {
                        Image(systemName: "tray")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(.gray)
                            .frame(width: 64, height: 64)
                        Text("Leitner is empty.\nTap to add new Leitner.")
                            .foregroundColor(.gray)
                            .font(.system(.subheadline, design: .rounded))
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(width: 256, height: 256)
                .background(.ultraThickMaterial)
                .cornerRadius(24)
            }
            .frame(width: 256, height: 256)
            .cornerRadius(24)
            .onTapGesture {
                viewModel.showEditOrAddLeitnerAlert.toggle()
            }
        }
    }
}

private struct GradientAnimationView: View {
    @State var isAnimating: Bool = false
    @State private var progress: CGFloat = 0
    
    var body: some View {
        Rectangle()
            .animatableGradient(from: [.purple, .green], toColor: [.yellow, .red], progress: progress)
            .opacity(0.8)
            .task {
                withAnimation(.easeOut(duration: 5).repeatForever(autoreverses: true)) {
                    isAnimating = true
                    progress = 1
                }
            }
    }
}

#Preview {
    EmptyLeitnerAnimation()
        .environmentObject(LeitnerViewModel(viewContext: PersistenceController.shared.viewContext))
}
