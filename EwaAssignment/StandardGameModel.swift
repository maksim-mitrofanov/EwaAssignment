//
//  StandardGameModel.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import SwiftUI

struct StandardGameModel: GameModelType {
    private(set) var state: GameState {
        didSet {
            stateChanged()
        }
    }
    private(set) var cards: [CardModel]
    
    init(cardCount: Int) {
        let maxNumber = max(0, cardCount)
        let validNumber = min(Symbol.allCases.count, maxNumber / 2)
        
        let randomSymbols = Array(Symbol.allCases.shuffled()[0..<validNumber])
        let duplicatedSymbols = randomSymbols + randomSymbols
        let cardModels = duplicatedSymbols.map { CardModel(symbol: $0, isFaceUp: true) }
        
        self.cards = cardModels
        self.state = .noSelection
    }
    
    mutating func receive(action: GameAction) {
        switch action {
        case .selectCard(let id):
            selectCard(id: id)
            
        case .prepareForFlip:
            state = .noSelection
            
        case .shuffleCards:
            shuffleCards()
        }
    }
    
    private var isDisabled: Bool {
        state == .match || state == .miss
    }
}

extension StandardGameModel {
    private mutating func stateChanged() {
        switch self.state {
        case .oneCardFaceUp(index: let index):
            cards[index].isFaceUp = true
            
        case .twoCardsFaceUp(card1Index: let index1, card2Index: let index2):
            cards[index1].isFaceUp = true
            cards[index2].isFaceUp = true
            
            if cardsMatch(index1: index1, index2: index2) {
                state = .match
                cards[index1].isMatched = true
                cards[index2].isMatched = true
            } else {
                state = .miss
            }
            
        case .noSelection:
            cards.indices.forEach {
                if cards[$0].isMatched == false {
                    cards[$0].isFaceUp = false
                }
            }
        
        default: break
        }
        
        print("Current state: \(self.state)")
    }
    
    mutating private func selectCard(id: UUID) {
        guard let selectedCardIndex = getIndex(for: id) else { return }
        guard !isDisabled else { return }
        
        switch self.state {
        case .noSelection:
            state = .oneCardFaceUp(index: selectedCardIndex)
            
        case .oneCardFaceUp(index: let faceUpCardIndex):
            let faceUpCardID = cards[faceUpCardIndex].id
            let selectedCardID = cards[selectedCardIndex].id
            
            if faceUpCardID == selectedCardID {
                state = .noSelection
            } else {
                state = .twoCardsFaceUp(card1Index: faceUpCardIndex, card2Index: selectedCardIndex)
            }
            
        case .miss, .match:
            state = .oneCardFaceUp(index: selectedCardIndex)
            
        default: break
        }
    }
}

// State machine helper functions
private extension StandardGameModel {
    func getIndex(for cardID: UUID) -> Int? {
        cards.firstIndex { $0.id == cardID }
    }
    
    func cardsMatch(index1: Int, index2: Int) -> Bool {
        // matched cards don't match :)
        guard cards[index1].isMatched == false, cards[index1].isMatched == false
        else { return false }
        
        return cards[index1].symbolName == cards[index2].symbolName
    }
    
    mutating func shuffleCards() {
        cards.shuffle()
    }
}
