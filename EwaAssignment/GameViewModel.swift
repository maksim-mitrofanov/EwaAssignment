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
        game.flip(cardID: cardID)
    }
    
    func shuffle() {
        game.shuffleCards()
    }
    
    func createNewGame() {
        game = GameModel(cardCount: totalCardCount)
    }
    
    func startGame() {
        if !hasStartedGame {
            game.startGame()
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
