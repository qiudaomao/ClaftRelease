//
//  RuleCardView.swift
//  claft
//
//  Created by zfu on 2022/3/1.
//

import SwiftUI

struct RuleCardView: View {
    var rule: RuleItem
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                Text("\(rule.type)")
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                    .font(.system(size: 10))
                    .background(Color("tagBackground"))
                    .cornerRadius(8)
            }.padding(EdgeInsets(top: 2, leading: 8, bottom: 0, trailing: 8))
            VStack {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                    Text("\(rule.payload)")
                        .font(.system(size: 10))
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                HStack {
                    Image(systemName: "network")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                    Text("\(rule.proxy)")
                        .font(.system(size: 10))
                    Spacer()
                }.padding(EdgeInsets(top: 0, leading: 8, bottom: 2, trailing: 8))
            }
        }
        .frame(height: 36)
//        .background(Material.thickMaterial)
        .modifier(CardBackgroundModifier())
        .cornerRadius(8)
        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
    }
}

struct RuleCardView_Previews: PreviewProvider {
    static var previews: some View {
        RuleCardView(rule: RuleItem(payload: "google.com", proxy: "全局", type: "Domain"))
            .previewLayout(.fixed(width: 360, height: 100))
        RuleCardView(rule: RuleItem(payload: "google.com", proxy: "全局", type: "Domain"))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 360, height: 100))
    }
}
