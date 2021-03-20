import Foundation
import Combine

public final class Board: ObservableObject {
    let mode: Mode
    @Published
    public private(set) var isGameover: Bool
    @Published
    public private(set) var isStarted: Bool
    @Published
    public private(set) var winner: Square.OccupiedBy
    
    public let squares: [[Square]]
    let flatSquares: [Square]
    
    /// This matrix is used to find indexes to check all
    /// possible wining combinations
    private let wins: [[Int]] = [
        [0, 1, 2], // 0 Check first row.
        [3, 4, 5], // 1 Check second Row
        [6, 7, 8], // 2 Check third Row
        [0, 3, 6], // 3 Check first column
        [1, 4, 7], // 4 Check second Column
        [2, 5, 8], // 5 Check third Column
        [0, 4, 8], // 6 Check first Diagonal
        [2, 4, 6]  // 7 Check second Diagonal
    ]
    
    public init(mode: Mode = .multiplayer) {
        self.mode = mode
        self.squares = [
            [.init(.nobody, id: 0), .init(.nobody, id: 1), .init(.nobody, id: 2)],
            [.init(.nobody, id: 3), .init(.nobody, id: 4), .init(.nobody, id: 5)],
            [.init(.nobody, id: 6), .init(.nobody, id: 7), .init(.nobody, id: 8)],
        ]
        self.isGameover = false
        self.isStarted = false
        self.winner = .nobody
        self.flatSquares = squares.flatMap { $0 }
    }
    
    /// Allows to play against AI
    /// - Returns: indexPath the visitor will occupy
    @discardableResult
    public func visitorRandomMove() -> IndexPath {
        var section = Int.random(in: 0..<3)
        var item = Int.random(in: 0..<3)
        
        while isOccupied(at: .init(item: item, section: section)) && !isGameover {
            section = Int.random(in: 0..<3)
            item = Int.random(in: 0..<3)
        }
        squares[section][item].occupiedBy = .visitor
        checkGameStatus()
        return IndexPath(item: item, section: section)
    }
    
    public func occupy(at indexPath: IndexPath, with player: Square.OccupiedBy) throws {
        guard indexPath.item < 3, indexPath.section < 3 else {
            throw Error.invalid(indexPath: indexPath, function: #function, filePath: #filePath)
        }
        
        guard !isOccupied(at: indexPath) else {
            throw Error.cannotChangeOccupiedSquare(indexPath: indexPath, occupiedBy: player, function: #function, filePath: #filePath)
        }
        squares[indexPath.section][indexPath.item].occupiedBy = player
        
        checkGameStatus()

        guard !isGameover else { return }
        
        switch mode {
            case .multiplayer:
                break
            case .ai:
                visitorRandomMove()
        }
    }
    
    func isOccupied(at indexPath: IndexPath) -> Bool {
        return squares[indexPath.section][indexPath.item].occupiedBy != .nobody
    }
    
    public func resetGame() {
        for section in 0...2 {
            for item  in 0...2 {
                squares[section][item].occupiedBy = .nobody
                checkGameStatus()
            }
        }
        checkGameStatus()
    }
    
    // MARK: - Error
    
    enum Error: Swift.Error, CustomStringConvertible, Equatable {
        case invalid(indexPath: IndexPath, function: String, filePath: String)
        case cannotChangeOccupiedSquare(indexPath: IndexPath, occupiedBy: Square.OccupiedBy, function: String, filePath: String)
        
        var description: String {
            switch self {
                case .invalid(indexPath: let indexPath, function: let function, filePath: let filePath):
                    return """
                        ❌ Invalid indexPath: (\(indexPath.section), \(indexPath.item))
                            function: \(function)
                            filePath: \(filePath)

                        \(Board.self) is only 3x3 big!
                        """
                case .cannotChangeOccupiedSquare(indexPath: let indexPath, occupiedBy: let occupation, function: let function, filePath: let filePath):
                    return """
                        ❌ Tried to change an occupied square at \(indexPath) to \(occupation)
                            function: \(function)
                            filePath: \(filePath)
                        """
            }
        }
    }
    
    // MARK: - Private
    
    
    private func checkForWinner() -> Square.OccupiedBy {
        let candidates: [Square.OccupiedBy] = [.home, .visitor]
        for candidate in candidates {
            for i in 0..<8 {
                if flatSquares[wins[i][0]].occupiedBy == candidate,
                   flatSquares[wins[i][1]].occupiedBy == candidate,
                   flatSquares[wins[i][2]].occupiedBy == candidate {
                   return candidate
                }
            }
        }
        return .nobody
    }
    
    private func checkGameStatus() {
        let flatSquares: [Square] = squares.flatMap { $0 }
        isGameover = flatSquares.filter { $0.occupiedBy == .nobody }.count == 0
        // id is ignored in equality
        isStarted = flatSquares.contains(.init(.home, id: 0)) || flatSquares.contains(.init(.visitor, id: 0))
        winner = checkForWinner()
    }
}

public extension Board {
    enum Mode {
        case multiplayer, ai
    }
}
