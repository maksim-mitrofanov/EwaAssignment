//
//  CardModel.swift
//  EwaAssignment
//
//  Created by  Maksim on 03.04.24.
//

import Foundation

struct CardModel: Identifiable {
    let symbolName: String
    var isFaceUp: Bool
    
    let id: UUID = UUID()
}

extension CardModel {
    static var templates = CardSymbol.allCases.map { CardModel(symbolName: $0.rawValue, isFaceUp: true) }.shuffled()
}
