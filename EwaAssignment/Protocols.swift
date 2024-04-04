//
//  Protocols.swift
//  EwaAssignment
//
//  Created by  Maksim on 05.04.24.
//

import SwiftUI
import Foundation

// ToDo: create a protocol for CardData
protocol CardGameViewModel {
    var allCards: [CardModel] { get }
    var totalCardCount: Int { get }
    var gameState: GameState { get }
    var unmatchedPairsCount: Int { get }
    
    init(cardCount: Int)
    
    func startGame()
    func createNewGame()
    func shuffle()
    func prepareForNextFlip()
    func flip(cardID: UUID)
}

protocol CardGameModel {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    var cards: [CardModel] { get }
    
    init(cardCount: Int)
    
    mutating func receive(action: Action)
}

enum GameState: Equatable {
    case noSelection
    case oneCardFaceUp(index: Int)
    case twoCardsFaceUp(card1Index: Int, card2Index: Int)
    case match
    case miss
    
    var description: String {
        switch self {
        case .noSelection:
            return "No selection"
        case .oneCardFaceUp:
            return "One card face up"
        case .twoCardsFaceUp:
            return "Two cards face up"
        case .match:
            return "Match"
        case .miss:
            return "Miss"
        }
    }
    
    var color: Color {
        switch self {
        case .noSelection:
            return .gray
        case .oneCardFaceUp:
            return .blue
        case .twoCardsFaceUp:
            return .orange
        case .match:
            return .green
        case .miss:
            return .red
        }
    }
}

enum GameAction {
    case selectCard(id: UUID)
    case prepareForFlip
    case shuffleCards
}
