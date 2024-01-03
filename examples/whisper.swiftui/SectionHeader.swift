//
//  SectionHeader.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/3/24.
//

import SwiftUI

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
      Text(title),
      alignment: .leading
    )
  }
}
