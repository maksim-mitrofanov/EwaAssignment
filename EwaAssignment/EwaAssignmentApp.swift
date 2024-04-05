//
//  EwaAssignmentApp.swift
//  EwaAssignment
//
//  Created by  Maksim on 02.04.24.
//

import SwiftUI

@main
struct EwaAssignmentApp: App {
    var body: some Scene {
        WindowGroup {
            GameView(viewModel: StandardViewModel(game: StandardGameModel(cardCount: 16)))
        }
    }
}
