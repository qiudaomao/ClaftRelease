//
//  LogView.swift
//  claft
//
//  Created by zfu on 2022/2/28.
//

import SwiftUI
import Combine

struct LogItem {
    var type: String = ""
    var payload: String = ""
    var uuid = UUID()
}

struct LogView: View {
    @State var logs: [LogItem] = []
    @State var rect:CGRect = CGRect()
    @State var currentServerIdx = -1
    @State var orderMode:ConnectionOrder = .none
    @State private var cancellable = Set<AnyCancellable>()
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject var serverModel:ServerModel
    
    var server:Server
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    #if os(iOS)
                    if horizontalSizeClass == .compact {
                        ServerListView().environmentObject(serverModel)
                    }
                    #else
                    if rect.size.width > 30 {
                        ServerListView().environmentObject(serverModel)
                    }
                    #endif
                    if (rect.size.width > 40) {
                        ForEach(logs.reversed(), id: \.uuid) { logItem in
                            HStack {
                                Text("\(logItem.type)")
                                    .frame(width: 25)
                                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                                    .font(.system(size: 10))
                                    .background(Color("tagBackground"))
                                    .cornerRadius(8)
                                Text("\(logItem.payload)")
                                    .font(.system(size: 10))
                                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                                Spacer()
                            }
                            .frame(width: rect.size.width - 40, height: 26)
                        }
                    }
                }
            }
//                .background(Color("windowBackground"))
        }
        .onAppear {
            serverModel.$currentServerIndex.sink(receiveValue: { idx in
                if currentServerIdx >= 0 {
                    self.logs = []
                    let server = serverModel.servers[currentServerIdx]
                    server.websockets?.disconnect(.log)
                }
                let server = serverModel.servers[idx]
                server.websockets?.connect(.log)
                server.websockets?.logWebSocket.$logs.sink(receiveValue: { logs in
                    self.logs = logs.map({ item in
                        return LogItem(type: item.type, payload: item.payload, uuid: UUID())
                    })
                }).store(in: &cancellable)
                currentServerIdx = idx
            }).store(in: &cancellable)
        }
        .onDisappear {
            if currentServerIdx > 0 {
                serverModel.servers[currentServerIdx].websockets?.disconnect(.log)
            }
        }
        .navigationTitle("Logs")
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        let server = Server(id: 0, host: "127.0.0.1", port: "9090", secret: nil, https: false)
        Group {
            ConnectionsView(server: server)
            ConnectionsView(server: server)
                .previewInterfaceOrientation(.landscapeLeft)
                .preferredColorScheme(.dark)
        }
    }
}
