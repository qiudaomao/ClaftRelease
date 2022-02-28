//
//  ProxiesView.swift
//  claft
//
//  Created by zfu on 2021/11/29.
//

import SwiftUI

struct ProxiesView: View {
    var server: Server
    @ObservedObject var proxyModel:ProxyModel = ProxyModel()
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(proxyModel.proxiesData.proxies.items.filter({ proxy in
                        return proxy.type == "Selector" || proxy.type == "URLTest"
                    }), id: \.name) { item in
                        Text("\(item.name) - \(item.type)")
                            .multilineTextAlignment(.leading)
                    }
                }
            }
        }
        .onAppear {
            proxyModel.update(server)
        }
    }
}

struct ProxiesView_Previews: PreviewProvider {
    static var previews: some View {
//        let proxies = previewProxyData
        let server = Server(id: 0, host: "127.0.0.1", port: "9090", secret: nil, https: false)
        let proxyModel = ProxyModel()
        proxyModel.proxiesData = previewProxyData
        return ProxiesView(server:server, proxyModel: proxyModel)
    }
}
