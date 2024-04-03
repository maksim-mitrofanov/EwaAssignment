//
//  CardView.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import SwiftUI

// TODO:
// - Change flip animation.
// - Fix warning

struct CardView: View {
    let card: CardModel
    
    @State private var frontDegrees: Double = 0.0
    @State private var backDegrees: Double = 0.0
    
    var body: some View {
        ZStack {
            faceUpView
            faceDownView
        }
        .onChange(of: card.isFaceUp, perform: flipCardAnimation(_:))
        .onAppear { calculateInitialDegrees() }
    }
    
    private var faceDownView: some View {
        ZStack {
            baseShape
                .foregroundStyle(backgroundColor)
            baseShape
                .strokeBorder(lineWidth: strokeWidth)
                .foregroundStyle(Color.gray)
        }
            .aspectRatio(aspectRatio, contentMode: .fit)
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
    
    private let cornerRadius: CGFloat = 25.0
    private let aspectRatio: CGFloat = 1/1
    private let strokeWidth: CGFloat = 1.0
    private let backgroundColor = Color.gray.opacity(0.15)
    private let paddingFactor: CGFloat = 5
    private let animationDuration: CGFloat = 1
}

private extension CardView {
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
    
    func calculateInitialDegrees() {
        frontDegrees = card.isFaceUp ? 0 : 90
        backDegrees = card.isFaceUp ? -90 : 0
    }
    
    func flipCardAnimation(_ isFaceUp: Bool) {
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
}

#Preview("4 cards") {
    var model_1 = CardModel(symbol: .beats, isFaceUp: true)
    var model_2 = CardModel(symbol: .beats, isFaceUp: false)
    
    return VStack {
        CardView(card: model_1)
        CardView(card: model_2)
    }
}
