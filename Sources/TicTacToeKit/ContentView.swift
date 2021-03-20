import SwiftUI
import Combine

public struct ContentView: View {
    @EnvironmentObject var boardViewModel: BoardViewModel
    @State var reset: Bool = false
    @State var winnerColor: Color = BoardViewModel.noWinnerColor
    
    public init() {}
    
    public var body: some View {
        VStack {
            Spacer()
            HStack {
                Text(boardViewModel.winnerName)
                    .font(.title)
                    .padding()
                Spacer()
                Button("Reset") {
                    boardViewModel.board.resetGame()
                }
                .padding()
            }.padding()
            Divider()
            HStack {
                VStack {
                    createSquare(item: 0, section: 0)
                    createSquare(item: 0, section: 1)
                    createSquare(item: 0, section: 2)
                }.padding()
                VStack {
                    createSquare(item: 1, section: 0)
                    createSquare(item: 1, section: 1)
                    createSquare(item: 1, section: 2)
                }.padding()
                VStack {
                    createSquare(item: 2, section: 0)
                    createSquare(item: 2, section: 1)
                    createSquare(item: 2, section: 2)
                }.padding()
            }.padding()
            Spacer()
        }
        .background(winnerColor)
        .onReceive(boardViewModel.$winnerColor, perform: { color in
            self.winnerColor = color.opacity(0.2)
        })
        .ignoresSafeArea()
    }
}

// MARK: - Private

extension ContentView {
    private func createSquare(item: Int, section: Int) -> SquareView {
        return SquareView(square: boardViewModel.board.squares[section][item]) {
            do { try boardViewModel.board.occupy(at: .init(item: item, section: section), with: .home) } catch { print(error) }
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(Board())
    }
}
