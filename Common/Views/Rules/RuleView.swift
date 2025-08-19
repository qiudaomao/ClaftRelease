//
//  RuleView.swift
//  claft
//
//  Created by zfu on 2022/3/1.
//

import SwiftUI
import Combine

struct RuleView: View {
    @StateObject var ruleModel:RuleModel = RuleModel()
    @EnvironmentObject var serverModel:ServerModel
    @State private var cancelables = Set<AnyCancellable>()
    @State var rect:CGRect = CGRect()
    @State var rules:[RuleItem] = []
    @State var ruleProviders:[ProviderRuleItemData] = []
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    @EnvironmentObject var connectionOrderModel:ConnectionOrderModel
    @State var keyword: String = ""
    @State var keywordCancellable: AnyCancellable? = nil
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    #if os(iOS)
                    if horizontalSizeClass != .compact {
                        ServerListView()
                    }
                    #else
                    ServerListView()
                    #endif
                    if rect.size.width > 40 {
                        ForEach(ruleProviders.filter({ rule in
                            if keyword.lengthOfBytes(using: .utf8) == 0 {
                                return true
                            }
                            return rule.name.lowercased().contains(keyword.lowercased())
                        }), id: \.name) { item in
                            RuleProviderCardView(rule: item) {
                                print("update")
                                if let server = serverModel.currentServer {
                                    ruleModel.updateRuleProvider(server, item.name)
                                }
                            }
                            .frame(width: (rect.size.width > 960) ? 960 - 40 : rect.size.width - 40, height: 40)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                        }
                    }
                    if rect.size.width > 40 {
                        ForEach(rules.filter({ rule in
                            if keyword.lengthOfBytes(using: .utf8) == 0 {
                                return true
                            }
                            return rule.payload.lowercased().contains(keyword.lowercased())
                        }), id:\.uuid) { rule in
                            RuleCardView(rule: rule)
                                .frame(width: (rect.size.width > 960) ? 960 - 40 : rect.size.width - 40, height: 40)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
                            #if os(tvOS)
                                .focusable(true)
                            #endif
                        }
                    }
                }
                .padding([.bottom])
//                .frame(maxWidth: 960)
            }
        }.onAppear {
            ruleModel.$rules.sink { rules in
                self.rules = rules
            }.store(in: &cancelables)
            ruleModel.$ruleProviderData.sink{ provider in
                self.ruleProviders = provider?.providers.items.sorted(by: { a, b in
                    return a.name < b.name
                }) ?? []
            }.store(in: &cancelables)
            serverModel.$currentServerIndex.sink { idx in
                let server = serverModel.servers[idx]
                self.rules = []
                ruleModel.loadRule(server)
            }.store(in: &cancelables)
            keywordCancellable = self.connectionOrderModel.$searchKeyword
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .removeDuplicates()
                .sink(receiveValue: { keyword in
                    print("keyword change to '\(keyword)'")
                    withAnimation {
                        self.keyword = keyword
                    }
                })
        }
        .navigationTitle("Rules")
        .modifier(RulesSearchView(searchKeyword: $connectionOrderModel.searchKeyword))
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
}

struct RulesSearchView: ViewModifier {
    @Binding var searchKeyword: String

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .searchable(text: $searchKeyword, prompt: "Search rules")
        } else {
            content
        }
    }
}

struct RuleView_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        return RuleView().environmentObject(serverModel)
    }
}
