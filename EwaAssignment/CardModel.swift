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
    var isMatched: Bool
    let id: UUID = UUID()
}

extension CardModel {
    init(symbol: Symbol, isFaceUp: Bool = true, isMatched: Bool = false) {
        self.symbolName = symbol.rawValue
        self.isFaceUp = isFaceUp
        self.isMatched = isMatched
    }
}

extension CardModel {
    static var templates = Symbol.allCases.map { CardModel(symbol: $0, isFaceUp: true) }.shuffled()
}
