//
//  GameViewModel.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published private var game: GameModel
    @Published private var undealtCardIDs = [UUID]()
    
    private let cardCount: Int
    
    init(cardCount: Int) {
        self.cardCount = cardCount
        self.game = GameModel(cardCount: cardCount)
        game.cards.forEach { undealtCardIDs.append($0.id) }
    }
    
    var dealtCards: [CardModel] {
        game.cards.filter { card in !undealtCardIDs.contains(where: { $0 == card.id })}
    }
    
    var undealtCards: [CardModel] {
        game.cards.filter { card in undealtCardIDs.contains(where: { $0 == card.id })}
    }
    
    var allCards: [CardModel] {
        game.cards
    }
    
    var totalCardCount: Int {
        game.cards.count
    }
    
    func flip(cardID: UUID) {
        game.flip(cardID: cardID)
    }
    
    func deal(cardID: UUID) {
        undealtCardIDs.removeAll(where: { $0 == cardID })
    }
    
    func startNewGame() {
        game = GameModel(cardCount: cardCount)
        game.cards.forEach { undealtCardIDs.append($0.id) }
    }
}
