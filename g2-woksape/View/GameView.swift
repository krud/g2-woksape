import SwiftUI

struct GameView: View {
    @ObservedObject var game = GameViewModel()
    var body: some View {
        GeometryReader {
            (geometry: GeometryProxy) in
            self.drawBoard(boundingRect: geometry.size)
        }
        .gesture(game.getMoveGesture())
    }
    
    func drawBoard(boundingRect: CGSize) -> some View {
        let columns = self.game.nColumns
        let rows = self.game.nRows
        let blocksize = min(boundingRect.width/CGFloat(columns), boundingRect.height/CGFloat(rows))
        
        let xoffset = (boundingRect.width - blocksize*CGFloat(columns))/2
        let yoffset = (boundingRect.height - blocksize*CGFloat(rows))/2
        let gameBoard = self.game.gameBoard
        
        return ForEach(0...columns-1, id:\.self){(column:Int) in
            ForEach(0...rows-1, id:\.self){(row:Int) in
                Path { path in
                    let x = xoffset + blocksize * CGFloat(column)
                    let y = boundingRect.height - yoffset - blocksize*CGFloat(row+1)
                    
                    let rect = CGRect(x: x, y: y, width: blocksize, height: blocksize)
                    path.addRect(rect)
                }
                .fill(gameBoard[column][row].color)
                .onTapGesture {
                    self.game.toggleSqauare(row: row, column: column)
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
