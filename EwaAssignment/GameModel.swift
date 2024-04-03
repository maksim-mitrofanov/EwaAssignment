//
//  GameModel.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import Foundation

struct GameModel {
    private(set) var cards: [CardModel]
    
    init(cardCount: Int) {
        let maxNumber = max(0, cardCount)
        let validNumber = min(Symbol.allCases.count, maxNumber / 2)
        
        let randomSymbols = Array(Symbol.allCases.shuffled()[0..<validNumber])
        let duplicatedSymbols = randomSymbols + randomSymbols
        let cardModels = duplicatedSymbols.map { CardModel(symbol: $0, isFaceUp: true) }
        
        self.cards = cardModels
    }
    
    mutating func flip(cardID: UUID) {
        if let cardIndex = cards.firstIndex(where: { $0.id == cardID }) {
            cards[cardIndex].isFaceUp.toggle()
        }
    }
}
