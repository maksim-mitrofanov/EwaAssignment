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
    
    @State private var undealtCardIDs = [UUID]()
    @Namespace private var cardsNameSpace
        
    var body: some View {
        VStack {
            cardsGridView
            undealtCardsView
            buttonsView
        }
        .padding(.horizontal)
        .padding(.top, 100)
        .onChange(of: undealtCardIDs.count) { shuffleDealtCards() }
    }
    
    private var cardsGridView: some View {
        VStack {
            GeometryReader { proxy in
                LazyVGrid(columns: columns) {
                    ForEach(dealtCards) { cardData in
                        CardView(card: cardData, width: proxy.size.width / CGFloat(columns.count + 1))
                            .matchedGeometryEffect(id: cardData.id, in: cardsNameSpace)
                            .transition(AnyTransition.opacity)
                            .onTapGesture {
                                viewModel.flip(cardID: cardData.id)
                            }
                            .padding(2)
                    }
                }
            }
        }
    }
    
    private var undealtCardsView: some View {
        ZStack {
            ForEach(undealtCards) { cardData in
                CardView(card: cardData, width: deckCardWidth)
                    .matchedGeometryEffect(id: cardData.id, in: cardsNameSpace)
                    .transition(AnyTransition.opacity)
                    .offset(x: xOffset(for: cardData))
                    .offset(y: yOffset(for: cardData))
                    .rotationEffect(Angle(degrees: rotationOffset(for: cardData)))
            }
        }
    }
    
    private var buttonsView: some View {
        VStack {
            dealCardsButton
            newGameButton
        }
    }
    
    private var newGameButton: some View {
        Button("Новая Игра") {
            withAnimation {
                viewModel.createNewGame()
                viewModel.allCards.forEach { undealtCardIDs.append($0.id) }
            }
        }
    }
    
    private var dealCardsButton: some View {
        VStack {
            
            if !viewModel.hasStartedGame {
                Button("Раздать") {
                    for card in undealtCards {
                        withAnimation(dealAnimation(for: card)) {
                            deal(cardID: card.id)
                        }
                    }
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
    
    private func xOffset(for card: CardModel) -> CGFloat {
        var offset: CGFloat = 0
        
        if let cardIndex = viewModel.allCards.firstIndex(where: { $0.id == card.id }) {
            switch true {
            case (cardIndex % 3) == 2:  offset = 20
            case (cardIndex % 3) == 1:  offset = -20
            case (cardIndex % 3) == 0:  offset = 0
            default: offset = 0
            }
        }
        
        return offset
    }
    
    private func yOffset(for card: CardModel) -> CGFloat {
        var offset: CGFloat = 0
        
        if let cardIndex = viewModel.allCards.firstIndex(where: { $0.id == card.id }) {
            switch true {
            case (cardIndex % 3) == 2:  offset = -5
            case (cardIndex % 3) == 1:  offset = -5
            case (cardIndex % 3) == 0:  offset = 0
            default: offset = 0
            }
        }
        
        return offset
    }
    
    private func rotationOffset(for card: CardModel) -> CGFloat {
        var offset: CGFloat = 0
        
        if let cardIndex = viewModel.allCards.firstIndex(where: { $0.id == card.id }) {
            switch true {
            case (cardIndex % 3) == 2:  offset = 20
            case (cardIndex % 3) == 1:  offset = -20
            case (cardIndex % 3) == 0:  offset = 0
            default: offset = 0
            }
        }
        
        return offset
    }
    
    private func shuffleDealtCards() {
        if undealtCards.count == 0 {
            Task {
                try await Task.sleep(nanoseconds: UInt64(200_000_000 * viewModel.totalCardCount))
                
                await MainActor.run {
                    viewModel.startGame()
                }
                
                try await Task.sleep(nanoseconds: shuffleDelay)
                
                await MainActor.run {
                    withAnimation(.easeInOut(duration: shuffleDuration)) {
                        viewModel.shuffle()
                    }
                }
                
                try await Task.sleep(nanoseconds: shuffleDelay)
                
                await MainActor.run {
                    withAnimation(.easeInOut(duration: shuffleDuration)) {
                        viewModel.shuffle()
                    }
                }
                
                try await Task.sleep(nanoseconds: shuffleDelay)
                
                await MainActor.run {
                    withAnimation(.easeInOut(duration: shuffleDuration)) {
                        viewModel.shuffle()
                    }
                }
            }
        }
    }
    
    func deal(cardID: UUID) {
        undealtCardIDs.removeAll(where: { $0 == cardID })
    }
    
    var dealtCards: [CardModel] {
        viewModel.allCards.filter { card in !undealtCardIDs.contains(where: { $0 == card.id })}
    }
    
    var undealtCards: [CardModel] {
        viewModel.allCards.filter { card in undealtCardIDs.contains(where: { $0 == card.id })}
    }
    
    private let totalDealDuration: Double = 2
    private let dealDuration: Double = 0.5
    private let deckCardWidth: CGFloat = 50
    private var shuffleDuration: CGFloat { 0.6 }
    private var shuffleDelay: UInt64 { 500_000_000 }
}

#Preview {
    GameView()
}
