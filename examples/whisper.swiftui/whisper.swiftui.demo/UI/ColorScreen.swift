//
//  ColorScreen.swift
//  attentional.swiftui
//
//  Created by Ryan Rapp on 12/31/23.
//

import SwiftUI

struct ColorScreen: View {
    let color: Color
    
    var body: some View {
        color
    }
}

struct ColorScreen_Previews: PreviewProvider {
    static var previews: some View {
        ColorScreen(color: .red)
    }
}
