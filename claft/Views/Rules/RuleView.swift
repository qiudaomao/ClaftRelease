//
//  RuleView.swift
//  claft
//
//  Created by zfu on 2022/3/1.
//

import SwiftUI
import Combine

struct RuleView: View {
    @ObservedObject var ruleModel:RuleModel = RuleModel()
    @EnvironmentObject var serverModel:ServerModel
    @State private var cancelables = Set<AnyCancellable>()
    @State var rect:CGRect = CGRect()
    @State var rules:[RuleItem] = []
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ServerListView()
                    if rect.size.width > 40 {
                        ForEach(rules, id:\.uuid) { rule in
                            RuleCardView(rule: rule)
                                .frame(width: (rect.size.width > 960) ? 960 - 40 : rect.size.width - 40, height: 40)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 140, trailing: 0))
//                .frame(maxWidth: 960)
            }
        }.onAppear {
            ruleModel.$rules.sink { rules in
                self.rules = rules
            }.store(in: &cancelables)
            serverModel.$currentServerIndex.sink { idx in
                let server = serverModel.servers[idx]
                self.rules = []
                ruleModel.loadRule(server)
            }.store(in: &cancelables)
        }
        .navigationTitle("Rules")
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
}

struct RuleView_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        return RuleView().environmentObject(serverModel)
    }
}