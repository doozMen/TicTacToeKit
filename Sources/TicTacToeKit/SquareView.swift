import Foundation
import SwiftUI
import Combine

public struct SquareView: View {
    let square: Square
    @State var color = Color.gray
    @State var scale: CGFloat = 1
    
    let action: () -> Void
    
    public init(
        square: Square,
        action: @escaping () -> Void
    ) {
        self.action = action
        self.square = square
    }
    
    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: 44, height: 44)
            .gesture(
                TapGesture()
                    .onEnded {
                        action()
                        color = square.color
                    }
            ).onReceive(square.$color, perform: { color in
                self.color = color
            })
            .onReceive(square.$isWinner, perform: { isWinner in
                guard isWinner else {
                    self.scale = 1
                    return
                }
                self.scale = 1.15
            })
            .accessibilityIdentifier(square.accesibilityIdentifier)
            .accessibility(label: Text(square.accesibilityLabelText))
            .scaleEffect(scale)
            .animation(.spring(response: 0.75, dampingFraction:  0.2, blendDuration: 0.7))
    }
}

struct SquareView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SquareView(square: .init(.home, id: 1), action: { print("home pressed")})
            SquareView(square: .init(.nobody, id: 2), action: { print("nobody pressed")})
            SquareView(square: .init(.visitor, id: 3), action: { print("visitor pressed")})
        }
    }
}
