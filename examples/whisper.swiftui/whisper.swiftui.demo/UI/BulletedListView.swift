//
//  BulletedListView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/10/24.
//

import SwiftUI
import TailwindCSS_SwiftUI


struct BulletedListView: View {
    let from: [String?]
    
    init(from: [String?]) {
        self.from = from
    }
    
    var body: some View {
        
        
        VStack {
            ForEach(Array(from.enumerated()), id: \.0) { index, item in
                let num = index + 1;
                HStack(alignment: .firstTextBaseline, spacing: 8) {
//                    Image(systemName: "circle.fill")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 6, height: 6, alignment: .centerFirstTextBaseline)
//                        .foregroundColor(Theme.Color.gray600)
//                        .padding(.top, 3)
//                        .padding(.trailing, 4)
                    Text("\(num, specifier: "%d").")
                        .frame(maxWidth: 30, alignment: .trailingFirstTextBaseline)
                        .padding(.leading, -6)
                        .foregroundColor(Theme.Color.gray600)
                    Text(item ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }.padding(.leading, 0)
            }
        }
    }
}

#Preview {
    BulletedListView(from: ["Foo", "Bar"])
}
