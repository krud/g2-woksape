import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameModel = GameModel()
    
    var nRows: Int { gameModel.nRows }
    var nColumns: Int { gameModel.nColumns }
    
    var gameBoard: [[GameSquare]] {
        var board = gameModel.gameBoard.map {$0.map(convertSquare)}
        
        if let shadow = gameModel.shadow {
            for blockLocation in shadow.blocks {
                board[blockLocation.column + shadow.origin.column][blockLocation.row + shadow.origin.row] = GameSquare(color: findShadowColor(blockType: shadow.blockType))
            }
        }
        
        if let tetromino = gameModel.tetromino {
            for blockLocation in tetromino.blocks {
                board[blockLocation.column + tetromino.origin.column][blockLocation.row + tetromino.origin.row] = GameSquare(color: findColor(blockType: tetromino.blockType))
            }
        }
        return board
    }
    
    var anyCancellable: AnyCancellable?
    var lastMoveLocation: CGPoint?
    
    init() {
      anyCancellable = gameModel.objectWillChange.sink {
        self.objectWillChange.send()
      }
    }
    
    func convertSquare(block: GameBlock?) -> GameSquare {
        return GameSquare(color: findColor(blockType: block?.blockType))
    }
    
    func findColor(blockType: BlockType?) -> Color {
        switch blockType {
            case .i:
                return .gameLightBlue
            case .j:
                return .gameDarkBlue
            case .l:
                return .gameOrange
            case .o:
                return .gameYellow
            case .s:
                return .gameGreen
            case .t:
                return .gamePurple
            case .z:
                return .gameRed
            case .none:
                return .gameBlack
        }
    }
    
    func findShadowColor(blockType: BlockType?) -> Color {
        switch blockType {
            case .i:
                return .gameLightBlueShadow
            case .j:
                return .gameDarkBlueShadow
            case .l:
                return .gameOrangeShadow
            case .o:
                return .gameYellowShadow
            case .s:
                return .gameGreenShadow
            case .t:
                return .gamePurpleShadow
            case .z:
                return .gameRedShadow
        case .none:
            return .gameBlack
        }
    }
    
//    func toggleSqauare(row:Int, column: Int){
//        gameModel.toggleBlock(row: row, column: column)
//    }
    
    func getRotateGesture() -> some Gesture {
        return TapGesture()
            .onEnded({self.gameModel.rotateTetromino(clockwise: true)})
    }
    
    func getMoveGesture() -> some Gesture {
        return DragGesture()
            .onChanged(onMoveChanged(value:))
            .onEnded(onMoveEnded(_:))
    }
    
    func onMoveChanged(value: DragGesture.Value) {
        guard let start = lastMoveLocation else {
            lastMoveLocation = value.location
            return
        }
        let xDiff = value.location.x - start.x
        
        if xDiff > 10 {
            print("moving right")
            let _ = gameModel.moveTetrominoRight()
            lastMoveLocation = value.location
            return
        }
        if xDiff < -10 {
           print("moving left")
           let _ = gameModel.moveTetrominoLeft()
           lastMoveLocation = value.location
           return
       }
        
        let yDiff = value.location.y - start.y
        
        if yDiff < -10 {
            print("dropping")
            gameModel.dropTetromino()
            lastMoveLocation = value.location
            return
         }
         if yDiff  > 10 {
            print("moving down")
            let _ = gameModel.moveTetrominoDown()
            lastMoveLocation = value.location
            return
        }
    }
    
    func onMoveEnded(_: DragGesture.Value) {
        lastMoveLocation = nil
    }
}

struct GameSquare{
    var color: Color
}
