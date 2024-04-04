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
    @Published private(set) var gameState: GameModel.GameState?
    @Published private(set) var hasStartedGame: Bool = false
    
    private let cardCount: Int
    
    init(cardCount: Int) {
        self.cardCount = cardCount
        self.game = GameModel(cardCount: cardCount)
        self.gameState = nil
    }
    
    func flip(cardID: UUID) {
        gameState = game.flip(cardID: cardID)
    }
    
    func prepareForNextFlip() {
        game.flipAllCards()
        gameState = .standard
    }
    
    func shuffle() {
        game.shuffleCards()
    }
    
    func createNewGame() {
        game = GameModel(cardCount: totalCardCount)
        hasStartedGame = false
    }
    
    func startGame() {
        if !hasStartedGame {
            game.flipAllCards()
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
}
