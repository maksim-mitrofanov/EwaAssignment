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
    init(symbol: Symbol, isFaceUp: Bool = true) {
        self.symbolName = symbol.rawValue
        self.isFaceUp = isFaceUp
    }
}

extension CardModel {
    static var templates = Symbol.allCases.map { CardModel(symbolName: $0.rawValue, isFaceUp: true) }.shuffled()
}
