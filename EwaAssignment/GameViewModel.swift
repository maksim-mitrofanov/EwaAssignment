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
    @Published private(set) var hasStartedGame: Bool = false
    
    private let cardCount: Int
    
    init(cardCount: Int) {
        self.cardCount = cardCount
        self.game = GameModel(cardCount: cardCount)
    }
    
    func flip(cardID: UUID) {
        game.receive(action: .selectCard(id: cardID))
        
        if gameState == .miss {
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
        hasStartedGame = false
    }
    
    func startGame() {
        if !hasStartedGame {
            game.receive(action: .prepareForFlip)
            hasStartedGame = true
        }
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
}
