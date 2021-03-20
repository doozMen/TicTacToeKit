import Foundation
import XCTest
@testable import TicTacToeKit

final class BoardTests: XCTestCase {
    var board: Board!
    override func setUp() {
        super.setUp()
        board = Board()
    }
    
    override func tearDown() {
        board = nil
        super.tearDown()
    }
    
    func test_squard_valid_ids() {
        XCTAssertEqual(board.flatSquares.map { $0.id }, [0, 1, 2, 3, 4, 5, 6, 7, 8])
    }
    
    func test_board_initial_nobody_on_any_square() {
        XCTAssertFalse(board.isStarted)
    }
    
    func test_board_started() throws {
        try board.occupy(at: .init(item: 0, section: 1), with: .home)
        
        XCTAssertTrue(board.isStarted)
    }
    
    func test_board_reset() throws {
        try board.occupy(at: .init(item: 0, section: 1), with: .home)
        XCTAssertTrue(board.isStarted)
        board.resetGame()
        
        XCTAssertFalse(board.isStarted)
        XCTAssertFalse(board.isGameover)
    }
    
    func test_out_of_bounds_occupy() throws {
        XCTAssertThrowsError(try board.occupy(at: .init(item: 9, section: 9), with: .home))
    }
    
    func test_do_not_allow_to_change_occupied_square() throws {
        try board.occupy(at: .init(item: 0, section: 1), with: .home)
        XCTAssertThrowsError(try board.occupy(at: .init(item: 0, section: 1), with: .visitor) , "you cannot change an occupied square") { error in
            guard let error = error as? Board.Error else {
                XCTFail()
                return
            }
            if case Board.Error.cannotChangeOccupiedSquare = error {
                
            } else {
                XCTFail()
            }
        }
    }
    
    // MARK: - Occupied
    
    func test_square_occupied() throws {
        let indexPath = IndexPath(item: 0, section: 0)
        try board.occupy(at: indexPath, with: .home)
        XCTAssertTrue(board.isOccupied(at: indexPath))
    }
    
    // MARK: - Gameover
    
    func test_board_gameover() throws {
        var result = false
        var callCount = 0
        let cancelable = board
            .$isGameover
            .removeDuplicates()
            .sink { isGameOver in
                result = isGameOver
                callCount += 1
            }

        XCTAssertFalse(result, "initially the game should be ongoing")

        for section in 0...2 {
            for item  in 0...2 {
                try board.occupy(at: .init(item: item, section: section), with: .home)
            }
        }

        XCTAssertEqual(callCount, 2, "as the value of isGameover changes initialy and when it is gameover this should be exacly 2")

        XCTAssertTrue(result, "A game ends if there are no more boxes available or if one of the two players align three symbols before the other.")
        
        cancelable.cancel()
    }

    func test_board_almost_gameover() throws {
        var result = false
        var callCount = 0
        let cancelable = board
            .$isGameover
            .removeDuplicates()
            .sink { isGameOver in
                result = isGameOver
                callCount += 1
            }
        
        XCTAssertFalse(result, "initially the game should be ongoing")
        
        for section in 1...2 {
            for item  in 0...2 {
                try board.occupy(at: .init(item: item, section: section), with: .home)
            }
        }
        
        XCTAssertEqual(callCount, 1, "there is no value change for gameOver so this should stay false")
        
        XCTAssertFalse(result, "left one square occupied by nobody so game is not yet over")
        
        cancelable.cancel()
    }
    
    // MARK: - Random
    
    func test_visitor_random_move() throws {
        let board = Board(mode: .ai)
        XCTAssertFalse(board.isStarted)
        board.visitorRandomMove()
        XCTAssertTrue(board.isStarted)
    }
    
    func test_visitor_random_move_different_every_time() throws {
        let board = Board(mode: .ai)
        let indexPath = board.visitorRandomMove()
        XCTAssertTrue(board.isStarted)
        let indexPath2 = board.visitorRandomMove()
        
        XCTAssertNotEqual(indexPath, indexPath2)
    }
    
    // MARK: - Winners
    
    func test_check_winner_rows() throws {
        XCTAssertEqual(board.winner, .nobody)
        let candidates: [Square.OccupiedBy] = [.home, .visitor]

        for candidate in candidates {
            for row in 0..<3 {
                try makeAWinningRow(in: board, row: row, candidate: candidate)

                XCTAssertEqual(board.winner, candidate)
                board.resetGame()
            }
        }
    }
    
    func test_square_marked_as_winner() throws {
        try makeAWinningRow(in: board, row: 0, candidate: .home)
        
        XCTAssertEqual(board.winner, .home)
        XCTAssertEqual(board.flatSquares.map { $0.isWinner }, [true, true, true, false, false, false, false, false, false])
    }
    
    func test_check_winner_columns() throws {
        XCTAssertEqual(board.winner, .nobody)
        let candidates: [Square.OccupiedBy] = [.home, .visitor]
        
        for candidate in candidates {
            for column in 0..<3 {
                try board.occupy(at: .init(item: column, section: 0), with: candidate)
                try board.occupy(at: .init(item: column, section: 1), with: candidate)
                try board.occupy(at: .init(item: column, section: 2), with: candidate)
                
                XCTAssertEqual(board.winner, candidate)
                board.resetGame()
            }
        }
    }
    
    func test_check_winner_diagonals() throws {
        XCTAssertEqual(board.winner, .nobody)
        let candidates: [Square.OccupiedBy] = [.home, .visitor]
        
        for candidate in candidates {
            try board.occupy(at: .init(item: 0, section: 0), with: candidate)
            try board.occupy(at: .init(item: 1, section: 1), with: candidate)
            try board.occupy(at: .init(item: 2, section: 2), with: candidate)
            
            XCTAssertEqual(board.winner, candidate)
            board.resetGame()
        }
        
        for candidate in candidates {
            try board.occupy(at: .init(item: 2, section: 0), with: candidate)
            try board.occupy(at: .init(item: 1, section: 1), with: candidate)
            try board.occupy(at: .init(item: 0, section: 2), with: candidate)
            
            XCTAssertEqual(board.winner, candidate)
            board.resetGame()
        }
    }
}

func makeAWinningRow(in board: Board, row: Int, candidate: Square.OccupiedBy) throws {
    try board.occupy(at: .init(item: 0, section: row), with: candidate)
    try board.occupy(at: .init(item: 1, section: row), with: candidate)
    try board.occupy(at: .init(item: 2, section: row), with: candidate)
}
