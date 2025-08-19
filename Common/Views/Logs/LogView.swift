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
                    if (rect.size.width > 40) {
                        ForEach(logs.reversed().filter({ log in
                            if keyword.lengthOfBytes(using: .utf8) == 0 {
                                return true
                            }
                            return "\(log.type)\(log.payload)".lowercased().contains(keyword.lowercased())
                        }), id: \.uuid) { logItem in
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
                            #if os(tvOS)
                            .focusable(true)
                            #endif
                            .frame(width: rect.size.width - 40, height: 26)
                            .padding(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
//                            .background(Material.thickMaterial)
                            .modifier(CardBackgroundModifier())
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 140, trailing: 0))
            }
            .frame(maxWidth: 1024)
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
                    withAnimation {
                        self.logs = logs.map({ item in
                            return LogItem(type: item.type, payload: item.payload, uuid: UUID())
                        })
                    }
                }).store(in: &cancellable)
                currentServerIdx = idx
            }).store(in: &cancellable)
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
        .onDisappear {
            if currentServerIdx > 0 {
                serverModel.servers[currentServerIdx].websockets?.disconnect(.log)
            }
        }
        .navigationTitle("Logs")
        .modifier(LogsSearchView(searchKeyword: $connectionOrderModel.searchKeyword))
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
}

struct LogsSearchView: ViewModifier {
    @Binding var searchKeyword: String

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .searchable(text: $searchKeyword, prompt: "Search logs")
        } else {
            content
        }
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LogView()
            LogView()
//                .previewInterfaceOrientation(.landscapeLeft)
                .preferredColorScheme(.dark)
        }
    }
}
