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
    @StateObject var proxyModel:ProxyModel = ProxyModel()
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
//    @ObservedObject var proxyModel:ProxyModel = ProxyModel()
    @State var proxiesData:ProxiesData = ProxiesData()
    @State var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()
    @State var changeProxyCancellable:AnyCancellable? = nil
    @State var renderDatas:[RenderData] = []
    @State var currentSelection: Int = 0
    @State var keyword: String = ""
    @State var keywordCancellable: AnyCancellable? = nil
    @State private var rect: CGRect = .zero
    #if os(tvOS)
    @FocusState var focused: ProxiesFocusable?
    #endif

    var expandBody: some View {
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
                        if item.isProvider {
                            if let updateAt = item.updateAt?.updateStr {
                                HStack {
                                    Text("\("Update at ".localized) \(updateAt)")
                                        .font(Font.system(size: 10))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                            }
                        }
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
                    if renderDatas.count > 0 {
//                        let itemNow = renderDatas[currentSelection]
                        let proxies = item.items.filter({ item in
                            return item.type != "Selector"
                                    && item.type != "URLTest"
                                    && item.fromProvider == false
                                    && item.name != "DIRECT"
                                    && item.name != "REJECT"
                        }).map { item in
                            item.name
                        }
                    HStack {
                        if item.isProvider {
                            Image(systemName: "link")
                            Text("\(item.name)")
                                .foregroundColor(.secondary)
                            Spacer()
                        } else {
                            Text("\(item.name) - \(item.now)")
                                .lineLimit(1)
                        }
                        Spacer()
                        if item.isProvider {
                            Image(systemName: "arrow.counterclockwise")
                                .onTapGesture {
                                    //check network delays
                                    print("update now")
                                    let server = serverModel.servers[serverModel.currentServerIndex]
                                    proxyModel.updateProvider(server, item.name)
                                }
                        }
                        if proxies.count > 0 {
                            Image(systemName: "speedometer")
                                .onTapGesture {
                                    //check network delays
                                    print("check network delays")
                                    if item.isProvider {
                                        let server = serverModel.servers[serverModel.currentServerIndex]
                                        proxyModel.checkHealthy(server, item.name)
                                    } else {
                                        let server = serverModel.servers[serverModel.currentServerIndex]
                                        if proxies.count > 0 {
                                            proxyModel.updateDelay(server, proxies: proxies)
                                        }
                                    }
                                }
                        }
                    }//.padding([.top, .leading, .trailing])
                    }
                    /*
                    HStack {
                        HStack {
                            Text("\(item.updateAt ?? item.name)")
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
                        if item.isProvider {
                            Image(systemName: "arrow.counterclockwise")
                                .onTapGesture {
                                    //check network delays
                                    print("update now")
                                    let server = serverModel.servers[serverModel.currentServerIndex]
                                    proxyModel.updateProvider(server, item.name)
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
                     */
                }
                .padding()
                #endif
            }
        }
        .padding()
    }
    
    var leftBody: some View {
        ScrollView {
            LazyVStack {
                ForEach(renderDatas.indices, id: \.self) { index in
                    if keyword.isEmpty || renderDatas[index].name.lowercased().contains(keyword) {
                        let item = renderDatas[index]
                        if index == currentSelection {
                            if rect.width > 40 {
                                HStack {
                                    if item.isProvider {
                                        Image(systemName: "link")
                                            .padding([.leading])
                                        Text("\(item.vehicleType ?? "")")
                                            .foregroundColor(.secondary)
                                        Spacer()
                                    }
                                    Text("\(item.name)")
                                        .padding([.trailing])
                                }
                                .frame(width: rect.width - 40, height: 40)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                                .onTapGesture {
                                    currentSelection = index
                                }
                            }
                        } else {
                            HStack {
                                if item.isProvider {
                                    Image(systemName: "link")
                                        .padding([.leading])
                                    Text("\(item.vehicleType ?? "")")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                Text("\(item.name)")
                                    .padding([.trailing])
                            }
                            .frame(width: rect.width - 40, height: 40)
                            .modifier(CardBackgroundModifier())
                            .cornerRadius(8)
                            .onTapGesture {
                                currentSelection = index
                            }
                        }
                    }
                }
            }
            .padding()
        }
        #if os(macOS)
        .frame(minWidth: 220, maxWidth: 220)
        #else
        .frame(maxWidth: 280)
        #endif
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
    
    var rightBody: some View {
        VStack {
            ScrollView {
                let columns:[GridItem] = Array(repeating: .init(.flexible()), count: 3)
                if renderDatas.count > 0 {
                    let item = renderDatas[currentSelection]
                    let proxies = item.items.filter({ item in
                        return item.type != "Selector"
                                && item.type != "URLTest"
                                && item.fromProvider == false
                                && item.name != "DIRECT"
                                && item.name != "REJECT"
                    }).map { item in
                        item.name
                    }
                HStack {
                    if item.isProvider {
                        Text("\(item.name) - Provider")
                                .lineLimit(1)
                    } else {
                        Text("\(item.name) - \(item.now)")
                                .lineLimit(1)
                    }
                    Spacer()
                    if item.isProvider {
                        Image(systemName: "arrow.counterclockwise")
                            .onTapGesture {
                                //check network delays
                                print("update now")
                                let server = serverModel.servers[serverModel.currentServerIndex]
                                proxyModel.updateProvider(server, item.name)
                            }
                    }
                    if proxies.count > 0 {
                        Image(systemName: "speedometer")
                            .onTapGesture {
                                //check network delays
                                print("check network delays")
                                if item.isProvider {
                                    let server = serverModel.servers[serverModel.currentServerIndex]
                                    proxyModel.checkHealthy(server, item.name)
                                } else {
                                    let server = serverModel.servers[serverModel.currentServerIndex]
                                    if proxies.count > 0 {
                                        proxyModel.updateDelay(server, proxies: proxies)
                                    }
                                }
                            }
                    }
                }.padding([.top, .leading, .trailing])
                    if item.isProvider {
                        if let updateAt = item.updateAt?.updateStr {
                            HStack {
                                Text("\("Update at ".localized) \(updateAt)")
                                    .font(Font.system(size: 10))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }.padding([.leading, .trailing])
                        }
                    }
                }
                LazyVGrid(columns: columns) {
                    if renderDatas.count > currentSelection {
                        ForEach($renderDatas[currentSelection].items, id: \.name) { $proxy in
                            ProxyCardView(proxy: $proxy, selected: renderDatas[currentSelection].now == proxy.name)
                                .gesture(TapGesture().onEnded({ _ in
                                    if renderDatas[currentSelection].isProvider {
                                        return
                                    }
                                    print("change \(renderDatas[currentSelection].name) => \(proxy.name)")
                                    guard let server = serverModel.currentServer else {
                                        return
                                    }
                                    proxyModel.changeProxy(server, renderDatas[currentSelection].name, proxy.name)
                                }))
                        }
                    }
                }
                .padding()
            }.frame(maxWidth: .infinity)
        }
    }
    
    var splitBody: some View {
        #if os(macOS)
        HSplitView {
            leftBody
            rightBody
        }
        #else
        HStack {
            leftBody
            rightBody
        }
        #endif
    }
    
    var body: some View {
        VStack {
#if os(iOS)
                if horizontalSizeClass != .compact {
                    ServerListView()
                    splitBody
                } else {
                    ScrollView {
                        expandBody
                    }
                }
#else
            ServerListView()
            splitBody
#endif
        }
        .navigationTitle("Proxies")
#if os(iOS)
        .searchable(text: $serverModel.searchKeyword, prompt: "Search proxies")
#endif
        .onAppear {
            serverModel.$currentServer.sink { server in
                guard let server = server else {
//                    proxyModel.proxiesData = ProxiesData()
                    renderDatas = []
                    return
                }
//                proxyModel.proxiesData = ProxiesData()
                renderDatas = []
                currentSelection = 0
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
                if datas.count > 0 {
                    print("now: \(datas[0].now)")
                }
                self.renderDatas = datas
            }.store(in: &cancellables)
            keywordCancellable = self.serverModel.$searchKeyword
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .removeDuplicates()
                .sink(receiveValue: { keyword in
                    print("keyword change to '\(keyword)'")
                    withAnimation {
                        self.keyword = keyword.lowercased()
                    }
                })
        }
    }
}

#if DEBUG
struct ProxiesView_Previews: PreviewProvider {
    static var previews: some View {
        let proxyModel = ProxyModel()
        proxyModel.proxiesData = previewProxyData
        return ProxiesView()
            .environmentObject(ServerModel())
            .environmentObject(proxyModel)
    }
}
#endif
