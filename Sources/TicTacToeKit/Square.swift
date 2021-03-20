import Foundation
import Combine
import SwiftUI

public final class Square: Equatable, CustomStringConvertible, ObservableObject {
    static let empty = "\(spacing) \(spacing)"
    static let spacing = "  "
    
    let id: Int
    lazy var accesibilityIdentifier = "\(Square.self)-\(id)"
    lazy var accesibilityLabelText = "\(Square.self) \(id)"
    
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
    
    public init(_ ownedBy: OccupiedBy, id: Int) {
        self.occupiedBy = ownedBy
        self.text = Square.empty
        self.color = .gray
        self.id = id
    }
    
    public var description: String {
        return """
        \(occupiedBy)
        """
    }
    
    // MARK: - Equatable
    
    /// Squared are considered unique if the occupiedBu is the same, other parameters are not considered.
    public static func == (lhs: Square, rhs: Square) -> Bool {
        lhs.occupiedBy == rhs.occupiedBy
    }
    
}

public extension Square {
    enum OccupiedBy: Equatable {
        case nobody, visitor, home
    }
}
