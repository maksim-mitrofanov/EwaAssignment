//
//  Assembly.swift
//  EwaAssignment
//
//  Created by  Maksim on 05.04.24.
//

import SwiftUI

// ToDo: Create other game types
enum Assembly {
    case standardGame
    
    func create(cardCount: Int) -> some View {
        let gameModel = StandardGameModel(cardCount: cardCount)
        let gameViewModel = StandardViewModel(game: gameModel)
        let gameView = GameView(viewModel: gameViewModel)
        return gameView
    }
}
