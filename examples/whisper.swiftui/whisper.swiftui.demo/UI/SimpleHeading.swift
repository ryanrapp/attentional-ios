//
//  SimpleHeading.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/4/24.
//

import SwiftUI
import TailwindCSS_SwiftUI

struct SimpleHeading: View {
    @State var title = ""
    @State var icon = "doc.text.fill"
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title.capitalized)
                .foregroundColor(Theme.Color.gray500) // Set the color as needed
                .font(.system(size: 16, weight: .bold, design: .default))
                .frame(maxWidth: .infinity, alignment: .leading)
                
        }.padding(.vertical, 4)
    }
}

#Preview {
    SimpleHeading()
}
