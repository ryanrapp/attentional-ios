//
//  MainView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 12/31/23.
//

import SwiftUI

struct MainView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ContentView() {
            dismiss()
        }
    }
}

#Preview {
    MainView()
}
