//
//  CardBackgroundModifier.swift
//  claft
//
//  Created by zfu on 2022/3/11.
//

import SwiftUI

struct CardBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(macOS)
        if #available(macOS 12.0, *) {
            content
                .background(Material.thickMaterial)
        } else {
            content
                .background(Color("connectionCard"))
        }
        #else
        if #available(iOS 15.0, *) {
            content
                .background(Material.thickMaterial)
        } else {
            content
                .background(Color("connectionCard"))
        }
        #endif
    }
}

struct CardBackgroundModifierView: View {
    var body: some View {
        Text("Hello, World!")
            .modifier(CardBackgroundModifier())
    }
}

struct CardBackgroundModifierView_Previews: PreviewProvider {
    static var previews: some View {
        CardBackgroundModifierView()
    }
}
