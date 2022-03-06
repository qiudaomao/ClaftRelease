//
//  ProxiesView.swift
//  claft
//
//  Created by zfu on 2021/11/29.
//

import SwiftUI
import Combine

struct ProxiesView: View {
    @EnvironmentObject var serverModel:ServerModel
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    @ObservedObject var proxyModel:ProxyModel = ProxyModel()
    @State var expanded:[Bool] = []
    @State var proxiesData:ProxiesData = ProxiesData()
    @State var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    @State var changeProxyCancellable:AnyCancellable? = nil
    var body: some View {
        VStack {
            ScrollView {
                ServerListView()
                LazyVStack(alignment: .leading) {
                    ForEach(0..<proxiesData.proxies.orderedSelections.count, id:\.self) { idx in
                        let item = proxiesData.proxies.orderedSelections[idx]
//                    ForEach(proxiesData.proxies.orderedSelections, id: \.uuid) { item in
                        DisclosureGroup("\(item.name)", isExpanded: $expanded[idx]) {
                            #if os(iOS)
                            let columns:[GridItem] = Array(repeating: .init(.flexible()), count: horizontalSizeClass == .compact ? 2:3)
                            #else
                            let columns:[GridItem] = Array(repeating: .init(.flexible()), count: 3)
                            #endif
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 4) {
                                    ForEach(item.all, id: \.self) { proxy in
                                        ProxyCardView(proxy: proxiesData.proxies.datas[proxy]!, selected: item.now == proxy)
                                            .gesture(TapGesture().onEnded({ _ in
                                                print("change \(item.name) => \(proxy)")
                                                changeProxyCancellable = serverModel.changeProxy(item.name, proxy)?.sink(receiveCompletion: { error in
                                                    print("complete \(error)")
                                                    let server = serverModel.servers[serverModel.currentServerIndex]
                                                    proxyModel.proxiesData = ProxiesData()
                                                    proxyModel.update(server)
                                                }, receiveValue: { value in
                                                    if let value = value {
                                                        print("\(value)")
                                                    }
                                                })
                                            }))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Proxies")
        .onAppear {
            proxyModel.$proxiesData.sink { data in
                if data.proxies.orderedSelections.count > 0 {
                    if expanded.count != data.proxies.orderedSelections.count {
                        expanded = data.proxies.orderedSelections.map({ _ in
                            return false
                        })
                    }
                }
                proxiesData = data
            }.store(in: &cancellables)
            serverModel.$currentServerIndex.sink { idx in
                let server = serverModel.servers[idx]
                proxyModel.proxiesData = ProxiesData()
                expanded = []
                proxyModel.update(server)
            }.store(in: &cancellables)
        }
    }
}

#if DEBUG
struct ProxiesView_Previews: PreviewProvider {
    static var previews: some View {
        let proxyModel = ProxyModel()
        proxyModel.proxiesData = previewProxyData
        return ProxiesView(proxyModel: proxyModel).environmentObject(ServerModel())
    }
}
#endif
