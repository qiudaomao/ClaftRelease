//
//  ProxiesView.swift
//  claft
//
//  Created by zfu on 2021/11/29.
//

import SwiftUI
import Combine

enum ProxiesFocusable: Hashable {
    case none
    case item(section: Int, proxy: String)
}

struct ProxiesView: View {
    @EnvironmentObject var serverModel:ServerModel
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    @ObservedObject var proxyModel:ProxyModel = ProxyModel()
    @State var proxiesData:ProxiesData = ProxiesData()
    @State var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    @State var changeProxyCancellable:AnyCancellable? = nil
    @State var renderDatas:[RenderData] = []
    #if os(tvOS)
    @FocusState var focused: ProxiesFocusable?
    #endif

    var body: some View {
        VStack {
            ScrollView {
                #if os(iOS)
                if horizontalSizeClass != .compact {
                    ServerListView()
                }
                #else
                ServerListView()
                #endif
                LazyVStack(alignment: .leading) {
                    ForEach($renderDatas, id: \.name) { $item in
//                        let item = renderDatas[idx]
//                    ForEach(proxiesData.proxies.orderedSelections, id: \.uuid) { item in
                        #if os(tvOS)
//                        Text("\(item.name)")
                        Section("\(item.name)") {
                            let columns:[GridItem] = Array(repeating: .init(.flexible()), count: 4)
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(item.all, id: \.self) { proxy in
                                        Button {
                                            proxyModel.changeProxy(serverModel.currentServer, item.name, proxy.name)
                                        } label: {
                                            ProxyCardView(proxy: proxiesData.proxies.datas[proxy]!, selected: item.now == proxy)
                                        }
                                        .buttonStyle(CardButtonStyle())
                                    }
                                }
                                .padding()
                            }
                        }
                        #else
                        DisclosureGroup(isExpanded: $item.expanded) {
                            #if os(iOS)
                            let columns:[GridItem] = Array(repeating: .init(.flexible()), count: horizontalSizeClass == .compact ? 2:3)
                            #else
                            let columns:[GridItem] = Array(repeating: .init(.flexible()), count: 3)
                            #endif
                            ScrollView {
                                LazyVGrid(columns: columns, spacing: 4) {
                                    ForEach($item.items, id: \.name) { $proxy in
                                        ProxyCardView(proxy: $proxy, selected: item.now == proxy.name)
                                            .gesture(TapGesture().onEnded({ _ in
                                                print("change \(item.name) => \(proxy)")
                                                guard let server = serverModel.currentServer else {
                                                    return
                                                }
                                                proxyModel.changeProxy(server, item.name, proxy.name)
                                            }))
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                HStack {
                                    Text("\(item.name)")
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.headline)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color("DisclosureGroupColor"))
                                .onTapGesture {
                                    withAnimation {
//                                        expanded[idx].toggle()
                                        item.expanded.toggle()
                                    }
                                }
                                Image(systemName: "speedometer")
                                    .onTapGesture {
                                        //check network delays
                                        print("check network delays")
                                        let server = serverModel.servers[serverModel.currentServerIndex]
                                        let proxies = item.items.filter({ item in
                                            return item.type != "Selector"
                                                    && item.type != "URLTest"
                                                    && item.fromProvider == false
                                        }).map { item in
                                            item.name
                                        }
                                        if proxies.count > 0 {
                                            proxyModel.updateDelay(server, proxies: proxies)
                                        }
                                    }
                            }
//                            .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                        }
                        .padding()
                        #endif
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Proxies")
        .onAppear {
            serverModel.$currentServer.sink { server in
                guard let server = server else {
                    proxyModel.proxiesData = ProxiesData()
                    renderDatas = []
                    return
                }
                proxyModel.proxiesData = ProxiesData()
                renderDatas = []
                proxyModel.update(server)
            }.store(in: &cancellables)
            proxyModel.$renderDatas.sink { datas_ in
                var datas = datas_
                for item in renderDatas.filter({ $0.expanded }) {
                    for i in 0..<renderDatas.count {
                        if renderDatas[i].name == item.name {
                            datas[i].expanded = true
                        }
                    }
                }
                self.renderDatas = datas
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
