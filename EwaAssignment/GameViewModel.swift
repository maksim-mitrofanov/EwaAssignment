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
    @Published private var undealtCardIDs = [UUID]()
    
    private let cardCount: Int
    
    init(cardCount: Int) {
        self.cardCount = cardCount
        self.game = GameModel(cardCount: cardCount)
        game.cards.forEach { undealtCardIDs.append($0.id) }
    }
    
    func flip(cardID: UUID) {
        game.flip(cardID: cardID)
    }
    
    func deal(cardID: UUID) {
        undealtCardIDs.removeAll(where: { $0 == cardID })
        
        Task {
            try await Task.sleep(nanoseconds: UInt64(200_000_000 * cardCount))
            
            await MainActor.run {
                game.startGame()
            }
            
            try await Task.sleep(nanoseconds: shuffleDelay)
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: shuffleDuration)) {
                    game.shuffleCards()
                }
            }
            
            try await Task.sleep(nanoseconds: shuffleDelay)
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: shuffleDuration)) {
                    game.shuffleCards()
                }
            }
            
            try await Task.sleep(nanoseconds: shuffleDelay)
            
            await MainActor.run {
                withAnimation(.easeInOut(duration: shuffleDuration)) {
                    game.shuffleCards()
                }
            }
        }
    }
    
    func shuffle() {
        game.shuffleCards()
    }
    
    func startNewGame() {
        game = GameModel(cardCount: cardCount)
        game.cards.forEach { undealtCardIDs.append($0.id) }
    }
}

extension GameViewModel {
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
    
    private var shuffleDuration: CGFloat { 0.6 }
    private var shuffleDelay: UInt64 { 500_000_000 }
}
