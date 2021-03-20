import XCTest
@testable import TicTacToeKit

class SquareTests: XCTestCase {
    var square: Square!

    override func setUp() {
        super.setUp()
        square = .init(.nobody, id: 0)
    }
    
    func test_square_accessibility() {
        XCTAssertEqual(square.accesibilityIdentifier, "")
        XCTAssertEqual(square.accesibilityLabelText, "")
    }
    
    func test_init() {
        XCTAssertEqual(square.occupiedBy, .nobody)
    }
    
    func test_text_equal_spacing() {
        square.occupiedBy = .home
        XCTAssertEqual(square.text, "  h  ")
        square.occupiedBy = .visitor
        XCTAssertEqual(square.text, "  v  ")
    }
    
    func test_text() {
        XCTAssertEqual(square.text, Square.empty)
    }
    
    func test_bindable_status() {
        var result = [Square.OccupiedBy]()
        let cancellable = square
            .$occupiedBy
            .collect(2)
            .sink { result = $0}
        square.occupiedBy = .home
        cancellable.cancel()
        XCTAssertEqual(result, [.nobody, .home])
    }
}
