//
//  EwaAssignmentGameModelTests.swift
//  EwaAssignmentGameModelTests
//
//  Created by  Maksim on 05.04.24.
//

import XCTest

final class EwaAssignmentGameModelTests: XCTestCase {
    
    var game: GameModelType!
    let gameTotalCardCount = 16

    override func setUp() {
        super.setUp()
        game = StandardGameModel(cardCount: gameTotalCardCount)
    }
    
    override func tearDown() {
        game = nil
        super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(game.state, .noSelection)
        XCTAssertEqual(game.cards.count, gameTotalCardCount)
    }

    // MARK: - Card Selection
    // when card is selected, it should be face up.
    func testReceiveSingleCardTap() {
        guard let randomCardIndex = game.cards.indices.randomElement() else { return }
        let randomCardID = game.cards[randomCardIndex].id
        
        game.receive(action: .selectCard(id: randomCardID))
        XCTAssertEqual(game.cards[randomCardIndex].isFaceUp, true)
        XCTAssertEqual(game.state, .oneCardFaceUp(index: randomCardIndex))
    }
    
    // when card is selected twice, it should be face down (face down -> face up -> face down)
    func testReceiveSingleCardDoubleTap() {
        guard let randomCardIndex = game.cards.indices.randomElement() else { return }
        let randomCardID = game.cards[randomCardIndex].id
        
        game.receive(action: .selectCard(id: randomCardID))
        XCTAssertEqual(game.cards[randomCardIndex].isFaceUp, true)
        XCTAssertEqual(game.state, .oneCardFaceUp(index: randomCardIndex))
        
        game.receive(action: .selectCard(id: randomCardID))
        XCTAssertEqual(game.cards[randomCardIndex].isFaceUp, false)
        XCTAssertEqual(game.state, .noSelection)
    }

    func testReceiveTwoRandomCardsTap() {
        guard let randomCard1Index = game.cards.indices.randomElement() else { return }
        guard let randomCard2Index = game.cards.indices.randomElement() else { return }
        
        guard randomCard1Index != randomCard2Index else {
            // ToDo: make sure testReceiveTwoDifferentCardsTap runs with two different cards at least once
            return
        }
        
        game.receive(action: .selectCard(id: game.cards[randomCard1Index].id))
        XCTAssertEqual(game.state, .oneCardFaceUp(index: randomCard1Index))
        
        game.receive(action: .selectCard(id: game.cards[randomCard2Index].id))
        
        XCTAssertEqual(game.cards[randomCard1Index].isFaceUp, true)
        XCTAssertEqual(game.cards[randomCard2Index].isFaceUp, true)
        
        XCTAssertNotEqual(game.state, .noSelection)
    }
    
    // MARK: - Matching
    func testReceiveTwoMatchingCardsTap() {
        guard let matchingCard1Index = game.cards.indices.randomElement() else { return }
        let cardSymbol = game.cards[matchingCard1Index].symbolName
        
        let matchingCardIndicies = game.cards.indices.filter({ game.cards[$0].symbolName == cardSymbol })
       
        // if more than two cards have same symbol, game can't be played
        XCTAssertEqual(matchingCardIndicies.count, 2)
        
        game.receive(action: .selectCard(id: game.cards[matchingCard1Index].id))
        game.receive(action: .selectCard(id: game.cards[matchingCardIndicies[0]].id))
        
        XCTAssertEqual(game.cards[matchingCard1Index].isFaceUp, true)
        XCTAssertEqual(game.cards[matchingCardIndicies[0]].isFaceUp, true)
        
        XCTAssertEqual(game.state, .match)
    }
    
    func testReceiveTwoNotMatchingCardsTap() {
        guard let matchingCard1Index = game.cards.indices.randomElement() else { return }
        let cardSymbol = game.cards[matchingCard1Index].symbolName
        
        let unmatchingCardIndicies = game.cards.indices.filter({ game.cards[$0].symbolName != cardSymbol })
       
        // if more than two cards have same symbol, game can't be played
        XCTAssert(unmatchingCardIndicies.count > 0)
        
        game.receive(action: .selectCard(id: game.cards[matchingCard1Index].id))
        game.receive(action: .selectCard(id: game.cards[unmatchingCardIndicies[0]].id))
        
        XCTAssertEqual(game.cards[matchingCard1Index].isFaceUp, true)
        XCTAssertEqual(game.cards[unmatchingCardIndicies[0]].isFaceUp, true)
        
        XCTAssertEqual(game.state, .miss)
    }
}
