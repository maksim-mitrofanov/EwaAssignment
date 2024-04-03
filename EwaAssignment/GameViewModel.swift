//
//  GameViewModel.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import Foundation

class GameViewModel: ObservableObject {
    @Published var game: GameModel
    
    init(cardCount: Int) {
        self.game = GameModel(cardCount: cardCount)
    }
    
    var cards: [CardModel] {
        game.cards
    }
    
    func flip(cardID: UUID) {
        game.flip(cardID: cardID)
    }
}
