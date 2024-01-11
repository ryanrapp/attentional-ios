//
//  SectionHeader.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/3/24.
//

import SwiftUI
import TailwindCSS_SwiftUI

struct SectionHeader<Content: View>: View {
    let title: String
    let icon: Image
    let content: Content

    init(title: String, icon: Image, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    var body: some View {
        HStack {
            icon.frame(width: 18, height: 18, alignment: .leading)
                .padding(.trailing, 6)
                .foregroundColor(Theme.Color.gray400)
            Text(title.capitalized)
                .foregroundColor(Color.black) // Set the color as needed
                .textCase(nil)
                .font(.sectionFont(ofSize: 22))
                .padding(.vertical, 10)
            
            Spacer()
            
            content
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 10)
    }
}

public func summarySectionHeader(title: String, imageName: String) -> some View {
    return SectionHeader(
        title: title,
        icon: Image(systemName: imageName),
        content: {
//                Menu{
//                    Button("Re-summarize", action: {
//                        print("Summarize clicked")
//                        summarizeInProgress = true
//                        Task {
//                            await viewModel.summarize(context: viewContext, record: record, apiKey: apiKey, useGpt4: useGpt4)
//                        }
//                    })
//                    Button("Cancel", action: {
//
//                    })
//                } label: {
//                    Label("", systemImage: "ellipsis")
//                } primaryAction: {
//
//                }
        }
    )
}



struct CollapsibleSectionHeader: View {
    
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
                    .font(.sectionFont(ofSize: 18))
                    .padding(.leading, 0)
                    .padding(.vertical, 20)
                Spacer()
            }
            ,
            alignment: .leading
        )
    }
}
