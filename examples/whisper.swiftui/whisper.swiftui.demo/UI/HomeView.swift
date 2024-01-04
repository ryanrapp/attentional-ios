//
//  HomeView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 12/31/23.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var actionHandler: ActionHandler
    @State var isHeaderOn: Bool = false

    var body: some View {
        NavigationStack {
            ListView().environmentObject(actionHandler)
        
        //            ColorScreen(color: .blue)
        //            ScrollView {
        //                VStack {
        ////                    HStack {
        ////                        Button(action: {
        ////                            Task {
        ////                                await whisperState.toggleRecord()
        ////                            }
        ////                        }) {
        ////                            if whisperState.isRecording {
        ////                                Image("stop") // Replace with your stop icon if available
        ////                                    .resizable()
        ////                                    .frame(width: 24, height: 24)
        ////                            } else {
        ////                                Image("mic") // Your custom Mic icon from Assets
        ////                                    .resizable()
        ////                                    .frame(width: 24, height: 24)
        ////                            }
        ////                        }
        ////                        .buttonStyle(.bordered)
        ////                        .disabled(!whisperState.canTranscribe)
        ////                    }
        ////                    Text(verbatim: whisperState.messageLog)
        ////                        .frame(maxWidth: .infinity, alignment: .leading)
        //                    ListView().frame(width: 100, height: 200)
        //                    .background(Color.red)
        //                    .padding() // Apply padding to the content inside the VStack
        //                }
        //            }
        .navigationTitle("Second Brain").frame(alignment: .top)
        //            .toolbar(content: {
        //                ToolbarItem(placement: .navigationBarLeading) {
        //                    Text("Attentional")
        //                        .bold()
        //                        .font(.largeTitle)
        //                }
        //            })
        
        // Don't apply padding to the entire ScrollView, only to its content
        }.edgesIgnoringSafeArea(.top)
            .padding(.top, -40) // removes the extra top padding added by not having a navigation title
        
    }
}

#Preview {
    HomeView()
}
