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
        
    mutating func flip(cardID: UUID) -> GameState {
        let faceUpCardIndicies = cards.indices.filter { cards[$0].isFaceUp == true }
        
        // Has no face up cards
        if faceUpCardIndicies.count == 0 {
            if let cardIndex = cards.firstIndex(where: { $0.id == cardID }) {
                cards[cardIndex].isFaceUp.toggle()
            }
        }
        
        // Has one face up card
        else {
            if let cardIndex = cards.firstIndex(where: { $0.id == cardID }) {
                cards[cardIndex].isFaceUp.toggle()
                
                let faceUpCardIndicies = cards.indices.filter { cards[$0].isFaceUp == true }
                let firstFaceUpCard = cards[faceUpCardIndicies[0]]
                let secondFaceUpCard = cards[faceUpCardIndicies[1]]
                
                if firstFaceUpCard.symbolName == secondFaceUpCard.symbolName {
                    return .match
                } else {
                    return .miss
                }
            }
        }
        
        return .standard
    }
    
    mutating func flipAllCards() {
        cards.indices.forEach { cards[$0].isFaceUp = false }
    }
        
    mutating func shuffleCards() {
        cards.shuffle()
    }
}

extension GameModel {
    enum GameState {
        case match
        case miss
        case standard
    }
}
