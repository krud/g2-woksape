import SwiftUI

class GameModel: ObservableObject {
    var nRows: Int
    var nColumns: Int
        
    @Published var gameBoard: [[GameBlock?]]
    @Published var tetromino: Tetromino?
        
    var timer: Timer?
    var speed: Double
    
    var shadow: Tetromino? {
        guard var lastShadow = tetromino else { return nil }
        var testShadow = lastShadow
        while(isValidTetromino(testTetromino: testShadow)) {
            lastShadow = testShadow
            testShadow = lastShadow.moveBy(row: -1, column: 0)
        }
        return lastShadow
    }
    
    init(nRows: Int = 23, nColumns: Int = 10) {
        self.nRows = nRows
        self.nColumns = nColumns
        
        gameBoard = Array(repeating: Array(repeating: nil, count: nRows), count: nColumns)
//        tetromino = Tetromino(origin: BlockLocation(row:22, column:4), blockType: .i)
        speed = 0.5
        
        resumeGame()
    }
    
//    func toggleBlock(row:Int, column: Int){
//        print("Column: \(column), Row: \(row)")
//
//        if gameBoard[column][row] == nil {
//            gameBoard[column][row]  = GameBlock(blockType: BlockType.allCases.randomElement()!)
//        } else {
//            gameBoard[column][row] = nil
//        }
//    }
    
    func resumeGame(){
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: speed, repeats: true, block: runEngine)
        
    }
    
    func pauseGame(){
        timer?.invalidate()
    }
    
    func runEngine(timer:Timer){
        
        if clearLines() {
            print("line cleared")
            return
        }
        guard tetromino != nil else {
            print("Spawning new tetromino")
            tetromino = Tetromino.createNewTetromino(nRows: nRows, nColumns: nColumns)
            if !isValidTetromino(testTetromino: tetromino!){
                print("GameOver")
                pauseGame()
            }
            return
        }
        
        if moveTetrominoDown() {
            print("Moving Tetromino down")
            return
        }
        
        print("placing Tetromino")
        placeTetromino()
        
    }
    
    func dropTetromino() {
        while(moveTetrominoDown()) { }
    }
    
    func moveTetrominoDown() -> Bool {
        return moveTetromino(rowOffset: -1, columnOffset: 0)
    }
    
    func moveTetrominoRight() -> Bool {
        return moveTetromino(rowOffset: 0, columnOffset: 1)
    }
    
    func moveTetrominoLeft() -> Bool {
        return moveTetromino(rowOffset: 0, columnOffset: -1)
    }
    
    func moveTetromino(rowOffset: Int, columnOffset: Int) -> Bool {
        
        guard let currentTetrimino = tetromino else { return false }
        
        let newTetromino = currentTetrimino.moveBy(row: rowOffset, column: columnOffset)
        if isValidTetromino(testTetromino: newTetromino) {
            tetromino = newTetromino
            return true
        }
        
        return false
    }
    
    func rotateTetromino(clockwise: Bool){
        guard let currentTetromino = tetromino else { return }
        
        let newTetromino = currentTetromino.rotate(clockwise: clockwise)
        if isValidTetromino(testTetromino: newTetromino){
            tetromino = newTetromino
        }
    }
    
    func isValidTetromino(testTetromino: Tetromino) -> Bool {
        for block in testTetromino.blocks {
            let row = testTetromino.origin.row + block.row
            if row < 0 || row >= nRows { return false }
            
            let column = testTetromino.origin.column + block.column
            if column < 0 || column >= nColumns { return false }
            
            if gameBoard[column][row] != nil { return false }
        }
        
        return true
    }
    
    func placeTetromino() {
        guard let currentTetromino = tetromino else {
            return
        }
        
        for block in currentTetromino.blocks {
            let row = currentTetromino.origin.row + block.row
            if row < 0 || row >= nRows { continue }
            
            let column = currentTetromino.origin.column + block.column
            if column < 0 || column >= nColumns { continue }
            
            gameBoard[column][row] = GameBlock(blockType: currentTetromino.blockType)
            
        }
        
        tetromino = nil
    }
    
    func clearLines() -> Bool {
        var newBoard: [[GameBlock?]] = Array(repeating: Array(repeating: nil, count: nRows), count:nColumns)
        var boardUpdated = false
        var nextRowToCopy = 0
        
        for row in 0...nRows-1 {
            var clearLine = true
            for column in 0...nColumns-1 {
                clearLine = clearLine && gameBoard[column][row] != nil
            }
            if !clearLine {
                for column in 0...nColumns-1 {
                    newBoard[column][nextRowToCopy] = gameBoard[column][row]
                }
                nextRowToCopy += 1
            }
            boardUpdated = boardUpdated || clearLine
        }
        if boardUpdated {
            gameBoard = newBoard
        }
        return boardUpdated
    }
}

struct GameBlock{
    var blockType: BlockType
}

enum BlockType: CaseIterable {
    case i, t, o, j, l, s, z
}

struct Tetromino {
    var origin:BlockLocation
    var blockType: BlockType
    var rotation: Int
    
    var blocks: [BlockLocation] {
        return Tetromino.getBlocks(blockType: blockType, rotation: rotation)
    }
    
    func moveBy(row: Int, column:Int) -> Tetromino {
        let newOrigin = BlockLocation(row: origin.row + row, column: origin.column + column)
        return Tetromino(origin: newOrigin, blockType: blockType, rotation: rotation)
    }
    
    func rotate(clockwise: Bool) -> Tetromino {
        return Tetromino(origin: origin, blockType: blockType, rotation: rotation + (clockwise ? 1 : -1))
    }
    
    static func getBlocks(blockType: BlockType, rotation: Int = 0) -> [BlockLocation] {
        let allBlocks = getAllBlocks(blockType: blockType)
        
        var index = rotation % allBlocks.count
        if (index < 0) { index += allBlocks.count }
        return allBlocks[index]
    }
    
    static func getAllBlocks(blockType: BlockType) -> [[BlockLocation]] {
        switch blockType {
            case .i:
                return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 2)],
                        [BlockLocation(row: -1, column: 1), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: -2, column: 1)],
                        [BlockLocation(row: -1, column: -1), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1), BlockLocation(row: -1, column: 2)],
                        [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: -2, column: 0)]]
            case .o:
                return [[BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1), BlockLocation(row: 1, column: 0)]]
            case .t:
                return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 0)],
                        [BlockLocation(row: -1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 0)],
                        [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 0)],
                        [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: -1, column: 0)]]
            case .j:
                return [[BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                        [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: 1, column: 1)],
                        [BlockLocation(row: -1, column: 1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                        [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: -1)]]
            case .l:
                return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: 1, column: 1)],
                        [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1)],
                        [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: -1)],
                        [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: 1, column: -1)]]
            case .s:
                return [[BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: 1, column: 0), BlockLocation(row: 1, column: 1)],
                        [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1), BlockLocation(row: -1, column: 1)],
                        [BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: -1)],
                        [BlockLocation(row: 1, column: -1), BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0)]]
            case .z:
                return [[BlockLocation(row: 1, column: -1), BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: 1)],
                        [BlockLocation(row: 1, column: 1), BlockLocation(row: 0, column: 1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0)],
                        [BlockLocation(row: 0, column: -1), BlockLocation(row: 0, column: 0), BlockLocation(row: -1, column: 0), BlockLocation(row: -1, column: 1)],
                        [BlockLocation(row: 1, column: 0), BlockLocation(row: 0, column: 0), BlockLocation(row: 0, column: -1), BlockLocation(row: -1, column: -1)]]
            }
        }
    
    static func createNewTetromino(nRows: Int, nColumns: Int) -> Tetromino {
        let blockType = BlockType.allCases.randomElement()!
        
        var maxRow = 0
        for block in getBlocks(blockType: blockType) {
            maxRow = max(maxRow, block.row)
        }
        
        let origin = BlockLocation(row: nRows - 1 - maxRow, column: (nColumns-1)/2)
        return Tetromino(origin: origin, blockType: blockType, rotation: 0)
    }
}

struct BlockLocation {
    var row: Int
    var column: Int
}
