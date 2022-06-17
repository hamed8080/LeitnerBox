//
//  PercentageView.swift
//  LeitnerBox
//
//  Created by hamed on 6/12/22.
//

import SwiftUI


struct PercentageView:View{
    
    @Binding
    var percent:Double
    
    @State
    var trimPercentage:CGFloat = 0
    
    @State
    var textPercentageAnimation:Double = 0
    
    var bottomText:Text = Text("")
    
    var body: some View{
        GeometryReader{ reader in
            ZStack{
                let thikness:CGFloat = 16
                let degrees:Double = 135 + (270 / 100) * percent
                let size = reader.size
                let center = CGPoint(x: size.width / 2, y: size.width / 2)
                let radius = (size.width / 2) - thikness
                
                Path{path in
                    path.addArc(center: center, radius: radius, startAngle: Angle(degrees: 135), endAngle: Angle(degrees: 45), clockwise: false)
                }
                .stroke(style: .init(lineWidth: thikness, lineCap: .round))
                .fill(Color.gray.opacity(0.5))
                
                Path{path in
                    path.addArc(center: center, radius: radius, startAngle: Angle(degrees: 135), endAngle: Angle(degrees: degrees), clockwise: false)
                }
                .trim(from: 0, to: trimPercentage)
                .stroke(style: .init(lineWidth: thikness, lineCap: .round))
                .fill(Color.purple.gradient)
                .animation(.spring(response: 0.3, dampingFraction: 0.2, blendDuration: 0.5), value: trimPercentage)
                .onAppear {
                    self.trimPercentage = 1
                }
                
                Text("\(String(format: "%.0f", textPercentageAnimation))%")
                    .fontWeight(.heavy)
                    .font(.system(size: 62, design: .rounded))
                    .onAppear{
                        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if textPercentageAnimation < percent{
                                    textPercentageAnimation += 1
                                }else{
                                    timer.invalidate()
                                }
                            }
                        }
                    }
                bottomText
                    .position(x: reader.size.width / 2,  y:reader.size.height - 42)
            }
        }
        
    }
}

struct PercentageView_Previews: PreviewProvider {
    
    static var previews: some View {
        PercentageView(percent: .constant(10), bottomText: Text("Total percent"))
            .frame(width:320, height: 320)
    }
}
