import Foundation
import Combine
import SwiftUI

public final class Square: Equatable, CustomStringConvertible, ObservableObject {
    static let empty = "\(spacing) \(spacing)"
    static let spacing = "  "
    
    @Published
    var occupiedBy: OccupiedBy {
        didSet {
            switch occupiedBy {
                case .nobody:
                    text = Square.empty
                    color = .gray
                case .visitor:
                    text = "\(Square.spacing)v\(Square.spacing)"
                    color = .green
                case .home:
                    text = "\(Square.spacing)h\(Square.spacing)"
                    color = .blue
            }
        }
    }
    
    @Published
    public var text: String
    @Published
    public var color: Color
    
    public init(_ ownedBy: OccupiedBy) {
        self.occupiedBy = ownedBy
        self.text = Square.empty
        self.color = .gray
    }
    
    public var description: String {
        return """
        \(occupiedBy)
        """
    }
    
    // MARK: - Equatable
    
    public static func == (lhs: Square, rhs: Square) -> Bool {
        lhs.occupiedBy == rhs.occupiedBy
    }
    
}

public extension Square {
    enum OccupiedBy: Equatable {
        case nobody, visitor, home
    }
}
