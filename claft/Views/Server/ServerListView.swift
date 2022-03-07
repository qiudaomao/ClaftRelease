//
//  ServerListView.swift
//  claft
//
//  Created by zfu on 2022/3/1.
//

import SwiftUI

enum Focusable: Hashable {
    case none
    case row(id: Int)
}

struct ServerListView: View {
    @EnvironmentObject var serverModel:ServerModel
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    #if os(tvOS)
    @FocusState var focused: Focusable?
    #endif
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(0..<serverModel.servers.count, id: \.self) { i in
                    #if os(tvOS)
                    Button {
                        serverModel.changeCurrentServer(i)
                    } label: {
                        ServerCard(server: serverModel.servers[i], trafficData: TrafficData(), selected: serverModel.currentServerIndex == i)
                    }
                    .buttonStyle(CardButtonStyle())
                    #else
                    ServerCard(server: serverModel.servers[i], trafficData: TrafficData(), selected: serverModel.currentServerIndex == i)
                        .gesture(TapGesture().onEnded({ _ in
                            serverModel.changeCurrentServer(i)
                        }))
                    #endif
                }
                .onDelete(perform: { indexSet in
                    serverModel.servers.remove(atOffsets: indexSet)
                })
                .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
            }
            #if os(iOS)
            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
            #else
            .padding(EdgeInsets(top: 0, leading: 22, bottom: 2, trailing: 0))
            #endif
        }
#if os(iOS)
        .frame(height: 62)
#elseif os(macOS)
        .frame(height: 78)
#else
        .frame(height: 240)
#endif
        #if os(tvOS)
        .onAppear() {
//            if serverModel.servers.count > 0 {
//                focused = .row(id: 0)
//            }
        }
        .onChange(of: focused) { value in
            guard let value = value else {
                return
            }
            print("focused changed to \(value)")
        }
        #endif
    }
}

struct ServerListView_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        serverModel.servers = [
            Server(id: 0, host: "192.168.23.1", port: "9191", secret: "061x09bg33"),
            Server(id: 1, host: "127.0.0.1", port: "9090", https: true),
            Server(id: 2, host: "serverC", port: "9091", secret: "abc"),
            Server(id: 3, host: "serverD", port: "9092", secret: "def", https: true)
        ]
        return ServerListView().environmentObject(serverModel)
    }
}
