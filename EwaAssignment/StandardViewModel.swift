//
//  StandardViewModel.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import SwiftUI
import Foundation

final class StandardViewModel: GameViewModelType, ObservableObject {
    @Published private var game: GameModelType
    
    init(game: any GameModelType = StandardGameModel(cardCount: 12)) {
        self.game = game
    }
    
    func flip(cardID: UUID) {
        game.receive(action: .selectCard(id: cardID))
        
        if game.state == .miss || game.state == .match {
            Task {
                try await Task.sleep(nanoseconds: delayForInteraction)
                
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
        game = StandardGameModel(cardCount: totalCardCount)
    }
    
    func startGame() {
        game.receive(action: .prepareForFlip)
    }
}

extension StandardViewModel {
    var allCards: [CardModel] {
        game.cards
    }
    
    var totalCardCount: Int {
        game.cards.count
    }
    
    var gameState: GameState {
        game.state
    }
    
    var unmatchedPairsCount: Int {
        game.cards.filter { $0.isMatched == false }.count / 2
    }
    
    private var delayForInteraction: UInt64 { 2_000_000_000 }
}
