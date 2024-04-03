//
//  CardView.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import SwiftUI

struct CardView: View {
    @State var card: CardModel
    
    @State private var frontDegrees: Double = 0.0
    @State private var backDegrees: Double = 0.0
    
    var body: some View {
        ZStack {
            faceUpView
            faceDownView
        }
        .overlay { debugMenu }
        .onTapGesture {
            card.isFaceUp.toggle()
        }
        .onChange(of: card.isFaceUp) { _, isFaceUp in
            if isFaceUp == false {
                withAnimation(.linear(duration: animationDuration)) {
                    frontDegrees = 90
                }
                withAnimation(.linear(duration: animationDuration).delay(animationDuration)) {
                    backDegrees = 0
                }
            }
            
            if isFaceUp {
                withAnimation(.linear(duration: animationDuration).delay(animationDuration)) {
                    frontDegrees = 0
                }
                
                withAnimation(.linear(duration: animationDuration)) {
                    backDegrees = -90
                }
            }
        }
        .onAppear {
            frontDegrees = card.isFaceUp ? 0 : 90
            backDegrees = card.isFaceUp ? -90 : 0
        }
    }
    
    private var faceDownView: some View {
        baseShape
//            .strokeBorder(lineWidth: strokeWidth)
            .aspectRatio(aspectRatio, contentMode: .fit)
            .foregroundStyle(Color.blue.opacity(0.8))
            .rotation3DEffect(
                Angle(degrees: backDegrees),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
    }
    
    private var faceUpView: some View {
        ZStack {
            baseShape
                .aspectRatio(aspectRatio, contentMode: .fit)
                .foregroundStyle(backgroundColor)
                .overlay { symbolOverlay }
                .rotation3DEffect(
                    Angle(degrees: frontDegrees),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
        }
    }
    
    private var symbolOverlay: some View {
        GeometryReader { proxy in
            Rectangle()
                .opacity(0)
                .overlay {
                    Image(systemName: card.symbolName)
                        .resizable()
                        .scaledToFit()
                }
                .padding(proxy.size.width / paddingFactor)
        }
    }
    
    private var debugMenu: some View {
        VStack {
            Text("IsFaceUp: \(card.isFaceUp.description)")
            Text("front: \(frontDegrees.description)")
            Text("back: \(backDegrees.description)")
        }
        .background {
            Color.white.opacity(1)
        }
        .offset(y: 20)
    }
    
    private var baseShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius)
    }
    
    private let cornerRadius: CGFloat = 25.0
    private let aspectRatio: CGFloat = 1/1
    private let strokeWidth: CGFloat = 1.0
    private let backgroundColor = Color.gray.opacity(0.15)
    private let paddingFactor: CGFloat = 5
    private let animationDuration: CGFloat = 1
}

#Preview("4 cards") {
    HStack {
        VStack {
            CardView(card: .templates[0])
            CardView(card: .templates[1])
        }
        
        VStack {
            CardView(card: .templates[4])
            CardView(card: .templates[5])
        }
    }
    .padding()
}
