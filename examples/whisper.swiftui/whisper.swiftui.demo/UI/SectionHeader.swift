//
//  SectionHeader.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/3/24.
//

import SwiftUI
import TailwindCSS_SwiftUI

struct SectionHeader: View {
  
  @State var title: String
  @Binding var isOn: Bool
  @State var onLabel: String
  @State var offLabel: String
  
  var body: some View {
    Button(action: {
      withAnimation {
        isOn.toggle()
      }
    }, label: {
      if isOn {
        Text(onLabel)
      } else {
        Text(offLabel)
      }
    })
    .font(Font.caption)
    .foregroundColor(.accentColor)
    .frame(maxWidth: .infinity, alignment: .trailing)
    .overlay(
        VStack {
            Text(title.capitalized)
                .foregroundColor(Theme.Color.gray500) // Set the color as needed
                .textCase(nil)
                .font(.system(size: 18, weight: .bold, design: .default))
                .padding(.leading, 0)
                .padding(.vertical, 20)
            Spacer()
        }
      ,
      alignment: .leading
    )
  }
}
