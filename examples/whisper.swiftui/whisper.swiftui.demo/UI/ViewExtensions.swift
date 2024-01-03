//
//  ViewExtensions.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 12/31/23.
//

import SwiftUI


class ActionHandler: ObservableObject {
    @Published var action: (() -> Void)?

    func performAction() {
        action?()
    }
}


extension View {
    func floatingAction(handler: ActionHandler) -> some View {
        ZStack(alignment: .bottom) {
            self
            
            Button(action: {
                handler.performAction()
            }) {
                Image(systemName: "plus")
                    .font(.title.weight(.semibold))
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.indigo)
                    .clipShape(Circle())
                    .shadow(radius: 4, x: 0, y: 4)
            }
            .padding()
        }
    }
}

