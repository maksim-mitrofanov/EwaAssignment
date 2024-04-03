//
//  GameView.swift
//  EwaAssignment
//
//  Created by  Maksim on 02.04.24.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel(cardCount: 4)
    
    var body: some View {
        VStack(spacing: 80) {
            ForEach(viewModel.cards) { cardData in
                CardView(card: cardData)
                    .onTapGesture {
                        viewModel.flip(cardID: cardData.id)
                    }
            }
        }
        .padding(.horizontal, 90)
    }
}

#Preview {
    GameView()
}
