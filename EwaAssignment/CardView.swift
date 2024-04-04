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
    let width: CGFloat
    
    @State private var frontDegrees: Double = 0.0
    @State private var backDegrees: Double = 0.0
    
    var body: some View {
        ZStack {
            faceUpView
            faceDownView
        }
        .frame(maxWidth: width)
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
    
    private var matchOverlay: some View {
        VStack {
            if card.isMatched {
                baseShape
                    .strokeBorder(lineWidth: strokeWidth)
                    .foregroundStyle(Color.green)
            }
        }
    }
    
    private var faceUpView: some View {
        ZStack {
            baseShape
                .aspectRatio(aspectRatio, contentMode: .fit)
                .foregroundStyle(backgroundColor)
                .overlay { symbolOverlay }
                .overlay { matchOverlay }
                .rotation3DEffect(
                    Angle(degrees: frontDegrees),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
        }
    }
    
    private var symbolOverlay: some View {
        Rectangle()
            .opacity(0)
            .overlay {
                Image(systemName: card.symbolName)
                    .resizable()
                    .scaledToFit()
            }
            .padding(width / paddingFactor)
    }
    
    private var cornerRadius: CGFloat { width / 5 }
    private let aspectRatio: CGFloat = 1/1
    private let strokeWidth: CGFloat = 1.0
    private let backgroundColor = Color.gray.opacity(0.15)
    private let paddingFactor: CGFloat = 5
    private let animationDuration: CGFloat = 0.15
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
    struct PreviewData: View {
        @StateObject var viewModel = GameViewModel(cardCount: 2)
        
        var body: some View {
            VStack(spacing: 80) {
                ForEach(viewModel.allCards) { cardData in
                    CardView(card: cardData, width: 150)
                        .onTapGesture {
                            viewModel.flip(cardID: cardData.id)
                        }
                }
            }.padding(.horizontal, 90)
        }
    }
    
    let preview = PreviewData()
    return preview
}
