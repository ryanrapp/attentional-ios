import SwiftUI
import AVFoundation

import TailwindCSS_SwiftUI


struct ContentView: View {
    @State var showSheet : Bool = false
    let onDismissClicked: ()->Void
    
    @State private var selectedTab: Int = 1
    @StateObject var actionHandler = ActionHandler()
    @AppStorage("username") var username: String = "Account"
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                HomeView()
                    .floatingAction(handler: actionHandler)
                    .environmentObject(actionHandler)
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }
                    .tag(1)
                
                ColorScreen(color: .green)
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Events")
                    }
                    .tag(2)
                
                ColorScreen(color: .blue)
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Search")
                    }
                    .tag(3)
                
                ColorScreen(color: .purple)
                    .edgesIgnoringSafeArea(.top)
                    .tabItem {
                        Image(systemName: "checklist")
                        Text("Todos")
                    }
                    .tag(4)
            }
            .accentColor(getColor())
            .toolbar {
                ToolbarItem {
                    Button {
                        showSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "person.fill")
                            Text(username)
                        }
                        
                    }
                }
            }.sheet(isPresented: $showSheet) {
                ConfigView()
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private func addAvRecord() -> Void {
        
    }

    private func getColor() -> Color {
        switch selectedTab {
            case 1:
                return .indigo
            case 2:
                return .green
            case 3:
                return .blue
            default:
                return .purple
        }
    }
}

//struct ContentView: View {
//    @State private var isSidebarVisible = false
//
//    var body: some View {
//        NavigationView {
//                    ZStack {
//                        // Main content
//                        HomeView()
//                            .navigationBarItems(leading: HamburgerButton(isSidebarVisible: $isSidebarVisible))
//                            .navigationBarTitle("Home", displayMode: .inline)
//
//                        // Sidebar
//                        if isSidebarVisible {
//                            SidebarView()
//                                .frame(width: 250)
//                                .transition(.move(edge: .leading))
//                        }
//                    }
//                    .gesture(dragGesture)
//                }
//            }
//
//            private var dragGesture: some Gesture {
//                DragGesture()
//                    .onEnded {
//                        if $0.translation.width > 100 {
//                            withAnimation {
//                                self.isSidebarVisible = true
//                            }
//                        }
//                    }
//            }
//        }
//
//        struct SidebarView: View {
//            var body: some View {
//                VStack {
//                    Text("Sidebar Item 1")
//                    Text("Sidebar Item 2")
//                    Spacer()
//                }
//                .background(Color.gray)
//                .edgesIgnoringSafeArea(.all)
//            }
//        }
//
//        struct HamburgerButton: View {
//            @Binding var isSidebarVisible: Bool
//
//            var body: some View {
//                Button(action: {
//                    withAnimation {
//                        self.isSidebarVisible.toggle()
//                    }
//                }) {
//                    Image(systemName: "line.horizontal.3")
//                        .imageScale(.large)
//                }
//            }
//        }


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() {}
    }
}
