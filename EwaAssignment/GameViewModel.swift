//
//  GameViewModel.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import SwiftUI
import Foundation

class GameViewModel: ObservableObject {
    @Published private var game: GameModel
    
    private let cardCount: Int
    
    init(cardCount: Int) {
        self.cardCount = cardCount
        self.game = GameModel(cardCount: cardCount)
    }
    
    func flip(cardID: UUID) {
        game.receive(action: .selectCard(id: cardID))
        
        if gameState == .miss || gameState == .match {
            Task {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                
                await MainActor.run {
                    game.receive(action: .prepareForFlip)
                }
            }
        }
    }
    
    func prepareForNextFlip() {
        game.receive(action: .prepareForFlip)
    }
    
    func shuffle() {
        game.receive(action: .shuffleCards)
    }
    
    func createNewGame() {
        game = GameModel(cardCount: totalCardCount)
    }
    
    func startGame() {
        game.receive(action: .prepareForFlip)
    }
}

extension GameViewModel {
    var allCards: [CardModel] {
        game.cards
    }
    
    var totalCardCount: Int {
        game.cards.count
    }
    
    var gameState: GameModel.State {
        game.state
    }
    
    var unmatchedPairsCount: Int {
        game.cards.filter { $0.isMatched == false }.count / 2
    }
}
