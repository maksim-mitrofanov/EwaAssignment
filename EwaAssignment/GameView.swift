//
//  GameView.swift
//  EwaAssignment
//
//  Created by  Maksim on 02.04.24.
//

import SwiftUI
import ConfettiSwiftUI

// TODO: Fix card Z Index.

struct GameView<ViewModelType: GameViewModelType>: View where ViewModelType: ObservableObject{
    @ObservedObject var viewModel: ViewModelType
    
    @State private var undealtCardIDs = [UUID]()
    @State private var confettiCounter = 0
    @Namespace private var cardsNameSpace
    
    init(viewModel: ViewModelType) {
        self.viewModel = viewModel
    }
        
    var body: some View {
        VStack {
            gameStateView()
            cardsGridView
            undealtCardsView
            undealtPairsCountView
            buttonsView
        }
        .padding(.horizontal)
        .padding(.top, 100)
        .onAppear { startNewGame() }
        .confettiCannon(counter: $confettiCounter, repetitions: 3, repetitionInterval: 0.7)
    }
    
    private func gameStateView() -> some View {
        Text(viewModel.gameState.description)
            .bold()
            .foregroundStyle(viewModel.gameState.color)
            .opacity(hasFinishedGame ? 0 : 1)
    }
    
    private var undealtPairsCountView: some View {
        VStack {
            if undealtCards.count == 0 {
                Text("Осталось найти: \(viewModel.unmatchedPairsCount) пар карт.")
            }
        }
        .opacity(hasFinishedGame ? 0 : 1)
    }
    
    private func showConfetti() {
        if hasFinishedGame {
            confettiCounter += 1
        }
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
        .opacity(hasFinishedGame ? 0.25 : 1)
        .onChange(of: viewModel.unmatchedPairsCount) { showConfetti() }
    }
    
    private var hasFinishedGame: Bool {
        viewModel.unmatchedPairsCount == 0
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
        .padding(.bottom)
    }
    
    private var buttonsView: some View {
        HStack {
            dealCardsButton
            newGameButton
        }
        .buttonStyle(.bordered)
    }
    
    private var newGameButton: some View {
        Button("Новая Игра") {
            startNewGame()
        }
    }
    
    private func startNewGame() {
        withAnimation {
            viewModel.createNewGame()
            viewModel.allCards.forEach { undealtCardIDs.append($0.id) }
        }
    }
    
    private var dealCardsButton: some View {
        VStack {
            if undealtCards.count > 0 {
                Button("Раздать") {
                    for card in undealtCards {
                        withAnimation(dealAnimation(for: card)) {
                            deal(cardID: card.id)
                        }
                    }
                    
                    shuffleDealtCards()
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
                
                for _ in 0..<shuffleCount {
                    try await waitAndShuffleCards()
                }
            }
        }
    }
    
    private func waitAndShuffleCards() async throws {
        try await Task.sleep(nanoseconds: shuffleDelay)
        
        await MainActor.run {
            withAnimation(.easeInOut(duration: shuffleDuration)) {
                viewModel.shuffle()
            }
        }
    }
    
    private func deal(cardID: UUID) {
        undealtCardIDs.removeAll(where: { $0 == cardID })
    }
    
    private var dealtCards: [CardModel] {
        viewModel.allCards.filter { card in !undealtCardIDs.contains(where: { $0 == card.id })}
    }
    
    private var undealtCards: [CardModel] {
        viewModel.allCards.filter { card in undealtCardIDs.contains(where: { $0 == card.id })}
    }
    
    private let totalDealDuration: Double = 2
    private let dealDuration: Double = 0.5
    private let deckCardWidth: CGFloat = 50
    private let shuffleCount = 2
    private var shuffleDuration: CGFloat = 0.6
    private var shuffleDelay: UInt64 { 500_000_000 }
}

#Preview {
    GameView(viewModel: StandardViewModel())
}
