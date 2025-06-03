//
//  RuleProviderCardView.swift
//  claft
//
//  Created by zfu on 2025/6/3.
//


/*
"behavior": "Classical",
"format": "YamlRule",
"name": "ChatGPT",
"ruleCount": 14,
"type": "Rule",
"vehicleType": "HTTP",
"updatedAt": "2025-06-03T02:16:53Z"
 */
//
//  RuleCardView.swift
//  claft
//
//  Created by zfu on 2022/3/1.
//

import SwiftUI

struct RuleProviderCardView: View {
    var rule: ProviderRuleItemData
    var doUpdate: (() -> Void)?
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                HStack {
                    Text("\(rule.ruleCount)")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .font(.system(size: 10))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                }
                HStack {
                    Text("\(rule.behavior)")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .font(.system(size: 10))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                        .frame(width: 60)
                }
                HStack {
                    Text("\(rule.vehicleType)")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .font(.system(size: 10))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                        .frame(width: 50)
                }
            }.padding(EdgeInsets(top: 2, leading: 8, bottom: 0, trailing: 8))
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                        Text("\(rule.name)")
                            .font(.system(size: 10))
                    }.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
//                    HStack {
//                        Image(systemName: "network")
//                            .font(.system(size: 10))
//                            .foregroundColor(.blue)
//                        Text("\(rule.vehicleType)")
//                            .font(.system(size: 10))
//                    }.padding(EdgeInsets(top: 0, leading: 8, bottom: 2, trailing: 8))
//                        .frame(width: 80)
//                    HStack {
//                        Image(systemName: "network")
//                            .font(.system(size: 10))
//                            .foregroundColor(.blue)
//                        Text("\(rule.behavior)")
//                            .font(.system(size: 10))
//                    }.padding(EdgeInsets(top: 0, leading: 8, bottom: 2, trailing: 8))
//                        .frame(width: 80)
                    Spacer()
                }
                HStack {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                            .onTapGesture {
                                //check network delays
                                print("update now")
                                doUpdate?()
                            }
                        Text("\(rule.updatedAt ?? "")")
                            .font(.system(size: 10))
                    }.padding(EdgeInsets(top: 0, leading: 8, bottom: 2, trailing: 8))
                    Spacer()
                }
            }
        }
        .frame(height: 42)
//        .background(Material.thickMaterial)
        .modifier(CardBackgroundModifier())
        .cornerRadius(8)
        .padding(EdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2))
    }
}

struct RuleProviderCardView_Previews: PreviewProvider {
    static var previews: some View {
        RuleProviderCardView(rule: ProviderRuleItemData(behavior: "Classical", format: "YamlRule", name: "ChatGPT", ruleCount: 14, type: "Rule", vehicleType: "HTTP", updatedAt: "2025-06-03T02:16:53Z"))
            .previewLayout(.fixed(width: 360, height: 200))
        RuleProviderCardView(rule: ProviderRuleItemData(behavior: "Classical", format: "YamlRule", name: "ChatGPT", ruleCount: 14, type: "Rule", vehicleType: "HTTP", updatedAt: "2025-06-03T02:16:53Z"))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 360, height: 200))
    }
}
