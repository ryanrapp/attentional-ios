//
//  ConfigView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/3/24.
//

import SwiftUI

struct ConfigView: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("apiKey") var apiKey: String = ""
    @AppStorage("useGpt4") var useGpt4: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Settings")) {
                TextField("User name", text: $username)
                TextField("OpenAI API Key", text: $apiKey)
                Toggle("Use GPT-4", isOn: $useGpt4)
            }
        }
    }
}

#Preview {
    ConfigView()
}
