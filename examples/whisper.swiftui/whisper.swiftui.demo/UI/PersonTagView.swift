//
//  PersonTagView.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 1/10/24.
//

import SwiftUI
import TailwindCSS_SwiftUI

struct PersonTagView: View {
    let group: SpeakerAnnotationGroup
    
    init(group: SpeakerAnnotationGroup) {
        self.group = group
    }
    
    var body: some View {
        HStack(spacing: 8) {
            Text(group.speakerInitials)
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(.white)
                .padding(8)
                .background(LinearGradient(gradient: Gradient(colors: [groupColors[group.index % groupColors.count], groupColors2[group.index % groupColors.count]]), startPoint: .topLeading, endPoint: .bottomTrailing))
                .clipShape(Circle())
                .shadow(radius: 1)
            Text(group.speakerName)
                .font(.system(size: 14, weight: .semibold, design: .default))
                .foregroundColor(Color.black)
            
        }.frame(minWidth: 0, alignment: .leading)
            .padding(.vertical, 0)
            .padding(.trailing, 8)
            .background(LinearGradient(gradient: Gradient(colors: [Theme.Color.gray100, Theme.Color.gray200]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(30)
    }
    
    private let groupColors = [Theme.Color.indigo400, Theme.Color.teal400, Theme.Color.orange400, Theme.Color.pink400, Theme.Color.blue400, Theme.Color.red400]
    private let groupColors2 = [Theme.Color.indigo700, Theme.Color.teal700, Theme.Color.orange700, Theme.Color.pink700, Theme.Color.blue700, Theme.Color.red700]
}

#Preview {
    PersonTagView(group: SpeakerAnnotationGroup(rows: [], index: 0))
}
