import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    var body: some View {
//        GameView()

            VStack {
                if viewRouter.currentPage == "landing" {
                    VStack{
                        Button(action: {self.viewRouter.currentPage = "maze"}) {
                            Text("Maze Game")
                        }
                        Button(action: {self.viewRouter.currentPage = "tetris"}) {
                            Text("Tetris")
                        }
                    }
                }
                if viewRouter.currentPage == "tetris" {
                     GameView()
                }
//                if viewRouter.currentPage == "signup" {
//                    SignupView().transition(.scale)
//                }
//                if viewRouter.currentPage == "profile" {
//                    ProfileTabView()
//                }
            }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(ViewRouter())
    }
}
