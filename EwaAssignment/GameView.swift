//
//  GameView.swift
//  EwaAssignment
//
//  Created by  Maksim on 02.04.24.
//

import SwiftUI

// TODO: Fix card Z Index.

struct GameView: View {
    @StateObject private var viewModel = GameViewModel(cardCount: 12)
    @Namespace private var cardsNameSpace
        
    var body: some View {
        VStack {
            cardsGridView
            undealtCardsView
            buttonsView
        }
        .padding(.horizontal)
        .padding(.top, 100)
    }
    
    private var cardsGridView: some View {
        VStack {
            GeometryReader { proxy in
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.dealtCards) { cardData in
                        CardView(card: cardData, width: proxy.size.width / CGFloat(columns.count + 1))
                            .matchedGeometryEffect(id: cardData.id, in: cardsNameSpace)
                            .transition(AnyTransition.opacity)
                            .onTapGesture {
                                viewModel.flip(cardID: cardData.id)
                            }
                            .padding(5)
                    }
                }
            }
        }
    }
    
    private var undealtCardsView: some View {
        ZStack {
            ForEach(viewModel.undealtCards) { cardData in
                CardView(card: cardData, width: deckCardWidth)
                    .matchedGeometryEffect(id: cardData.id, in: cardsNameSpace)
                    .transition(AnyTransition.opacity)
            }
        }
    }
    
    private var buttonsView: some View {
        VStack {
            dealCardsButton
            restartButton
        }
    }
    
    private var restartButton: some View {
        Button("Заново") {
            withAnimation { viewModel.startNewGame() }
        }
    }
    
    private var dealCardsButton: some View {
        Button("Раздать") {
            for card in viewModel.undealtCards {
                withAnimation(dealAnimation(for: card)) {
                    viewModel.deal(cardID: card.id)
                }
            }
        }
    }
    
    private var columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private func dealAnimation(for card: CardModel) -> Animation {
        var delay = 0.0
        
        if let cardIndex = viewModel.allCards.firstIndex(where: { $0.id == card.id }) {
            delay = Double(cardIndex) * Double(totalDealDuration / Double(viewModel.totalCardCount))
        }
        
        return Animation.easeInOut(duration: dealDuration).delay(delay)
    }
    
    private let totalDealDuration: Double = 2
    private let dealDuration: Double = 0.5
    private let deckCardWidth: CGFloat = 50
}

#Preview {
    GameView()
}
