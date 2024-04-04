//
//  GameModel.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import Foundation

struct GameModel {
    private(set) var state: State {
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
    
    mutating func receive(action: Action) {
        switch action {
        case .selectCard(let id):
            selectCard(id: id)
            
        case .prepareForFlip:
            flipAllCards()
            
        case .shuffleCards:
            shuffleCards()
        }
    }
}

extension GameModel {
    enum State: Equatable {
        case noSelection
        case oneCardFaceUp(index: Int)
        case twoCardsFaceUp(card1Index: Int, card2Index: Int)
        case match
        case miss
    }
    
    enum Action {
        case selectCard(id: UUID)
        case prepareForFlip
        case shuffleCards
    }
    
    private mutating func stateChanged() {
        switch self.state {
        case .oneCardFaceUp(index: let index):
            cards[index].isFaceUp = true
            
        case .twoCardsFaceUp(card1Index: let index1, card2Index: let index2):
            if cardsMatch(index1: index1, index2: index2) {
                state = .match
                cards[index1].isMatched = true
                cards[index2].isMatched = true
            } else {
                state = .miss
            }
            
        case .noSelection:
            flipAllCards()
            state = .noSelection
        
        default: break
        }
        
        print("Current state: \(self.state)")
    }
    
    mutating private func selectCard(id: UUID) {
        guard let selectedCardIndex = getIndex(for: id) else { return }
        
        switch self.state {
        case .noSelection:
            state = .oneCardFaceUp(index: selectedCardIndex)
            
        case .oneCardFaceUp(index: let faceUpCardIndex):
            let faceUpCardID = cards[faceUpCardIndex].id
            let selectedCardID = cards[selectedCardIndex].id
            
            if faceUpCardID == selectedCardID {
                cards[faceUpCardIndex].isFaceUp = false
                state = .noSelection
            } else {
                cards[selectedCardIndex].isFaceUp = true
                state = .twoCardsFaceUp(card1Index: faceUpCardIndex, card2Index: selectedCardIndex)
            }
            
        case .miss, .match:
            state = .oneCardFaceUp(index: selectedCardIndex)
            
        default: break
        }
    }
}

// State machine helper functions
private extension GameModel {
    func getIndex(for cardID: UUID) -> Int? {
        cards.firstIndex { $0.id == cardID }
    }
    
    mutating func flipAllCards() {
        cards.indices.forEach {
            if cards[$0].isMatched == false {
                cards[$0].isFaceUp = false
            }
        }
    }
    
    func cardsMatch(index1: Int, index2: Int) -> Bool {
        // matched cards don't match :)
        guard cards[index1].isMatched == false, cards[index1].isMatched == false
        else { return false }
        
        return cards[index1].symbolName == cards[index2].symbolName
    }
    
    mutating func shuffleCards() {
//        cards.shuffle()
    }
}
