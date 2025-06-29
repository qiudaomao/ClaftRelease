//
//  ConnectionsView.swift
//  claft
//
//  Created by zfu on 2022/2/27.
//

import SwiftUI
import Combine

struct GeometryGetterMod: ViewModifier {
    @Binding var rect: CGRect
    func body(content: Content) -> some View {
//        print(content)
        return GeometryReader { (g) -> Color in // (g) -> Content in - is what it could be, but it doesn't work
            DispatchQueue.main.async { // to avoid warning
                self.rect = g.frame(in: .global)
            }
            return Color.clear // return content - doesn't work
        }
    }
}

struct ConnectionsView: View {
    @State var connectionData: ConnectionData = ConnectionData()
    @State var connectionDataCancellable: AnyCancellable? = nil
    @State var currentServerIdxCancellable: AnyCancellable? = nil
    @State var orderCancellable: AnyCancellable? = nil
    @State var pauseCancellable: AnyCancellable? = nil
    @State var rect:CGRect = CGRect()
    @State var pause:Bool = false
    @State var showBottomSheet = false
    @State var isOpenBottomSheet = false
    @State var currentServerIdx = -1
    @State var orderMode:ConnectionOrder = .none
    @State var keyword: String = ""
    @State var keywordCancellable: AnyCancellable? = nil
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject var serverModel:ServerModel
    @EnvironmentObject var connectionOrderModel:ConnectionOrderModel
    
    func closeConnection(_ id:String) {
        let server = serverModel.servers[currentServerIdx]
        serverModel.deleteConnection(server, id)
    }
    
//    var server:Server
    var body: some View {
        ZStack {
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
                            ForEach(connectionData.connections
                                        .filter({ conn in
                                if keyword.lengthOfBytes(using: .utf8) == 0 {
                                    return true
                                }
                                let meta = conn.metadata
                                for item in conn.chains {
                                    if item.lowercased().contains(keyword) {
                                        return true
                                    }
                                }
                                return "\(meta.network) \(meta.type) \(meta.sourceIP) \(meta.destinationIP) \(meta.sourcePort) \(meta.destinationPort) \(meta.host) \(meta.dnsMode)".lowercased().contains(keyword)
                            })
                                        .sorted(by: { a, b in
                                if orderMode == .time {
                                    return a.start < b.start
                                } else if orderMode == .downloadSize {
                                    return a.download > b.download
                                } else if orderMode == .uploadSize {
                                    return a.upload > b.upload
                                } else if orderMode == .downloadSpeed {
                                    if let a = a.downloadSpeed, let b = b.downloadSpeed {
                                        return a > b
                                    } else if let _ = a.downloadSpeed {
                                        return true
                                    } else if let _ = b.downloadSpeed {
                                        return false
                                    } else {
                                        return a.download > b.download
                                    }
                                } else if orderMode == .uploadSpeed {
                                    if let a = a.uploadSpeed , let b = b.uploadSpeed{
                                        return a > b
                                    } else if let _ = a.uploadSpeed {
                                        return true
                                    } else if let _ = b.uploadSpeed {
                                        return false
                                    } else {
                                        return a.upload > b.upload
                                    }
                                }
                                return true
                            }), id: \.id) { connectionItem in
                                #if os(tvOS)
                                Button {
                                    self.showBottomSheet.toggle()
                                } label: {
                                    ConnectionCardView(callback: {
                                        print("ondelete \(connectionItem.id)")
                                        closeConnection(connectionItem.id)
                                    }, connectionItem: connectionItem)
                                        .frame(width: rect.size.width - 40)
//                                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                                }
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                                .buttonStyle(CardButtonStyle())
                                #else
                                ConnectionCardView(callback: {
                                    print("ondelete \(connectionItem.id)")
                                    closeConnection(connectionItem.id)
                                }, connectionItem: connectionItem)
                                    .frame(width: (rect.size.width > 960) ? 960 - 40 : rect.size.width - 40)
                                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                                #endif
                            }
                        }
                    }
                    #if os(iOS)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 160, trailing: 0))
                    #else
                    .padding([.bottom])
                    #endif
                }
                #if os(iOS)
//                .background(Color("windowBackground"))
                #endif
            }
            #if os(iOS) || os(tvOS)
            let name:String = self.pause ? "play.circle.fill":"pause.circle.fill"
            Image(systemName: name)
                .resizable()
                .foregroundColor(.blue)
            #if os(iOS)
                .frame(width: 60, height: 60)
                .background(Circle().foregroundColor(.white).frame(width: 50, height: 50))
                .position(x: rect.size.width - 56, y: rect.size.height - 50)
            #else
                .frame(width: 40, height: 40)
                .background(Circle().foregroundColor(.white).frame(width: 30, height: 30))
                .position(x: rect.size.width - 46, y: rect.size.height - 50)
            #endif
            #if os(tvOS)
                .onLongPressGesture(minimumDuration: 0.01, pressing: { _ in }) {
                    print("touched")
                    self.pause.toggle()
                }
            #else
                .gesture(TapGesture().onEnded({ () in
                    print("touched")
                    self.pause.toggle()
                }))
            #endif
            Image(systemName: "arrow.clockwise.circle.fill")
                .resizable()
                .foregroundColor(.blue)
            #if os(iOS)
                .frame(width: 60, height: 60)
                .background(Circle().foregroundColor(.white).frame(width: 50, height: 50))
                .position(x: rect.size.width - 56, y: rect.size.height - 130)
            #else
                .frame(width: 40, height: 40)
                .background(Circle().foregroundColor(.white).frame(width: 30, height: 30))
                .position(x: rect.size.width - 46, y: rect.size.height - 100)
            #endif
            #if os(tvOS)
                .onLongPressGesture(minimumDuration: 0.01, pressing: { _ in }) {
                    print("touched reorder")
                    self.showBottomSheet.toggle()
                }
            #else
                .gesture(TapGesture().onEnded({ () in
                    print("touched reorder")
                    self.showBottomSheet.toggle()
                }))
            #endif
            #endif
            
            #if os(iOS)
            if showBottomSheet {
                BottomSheetView(isOpen: self.$isOpenBottomSheet, maxHeight: 660) {
                    VStack {
                        Text("Sort By")
                            .font(.system(size: 23))
                            .padding()
                        Button(action: {
                            self.orderMode = .none
                            self.connectionOrderModel.saveOrder(.none)
                            self.showBottomSheet = false
                        }) {
                            Text("Default")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            self.orderMode = .time
                            self.connectionOrderModel.saveOrder(.time)
                            self.showBottomSheet = false
                        }) {
                            Text("Start Time")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            self.orderMode = .downloadSize
                            self.connectionOrderModel.saveOrder(.downloadSize)
                            self.showBottomSheet = false
                        }) {
                            Text("Download Size")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            self.orderMode = .uploadSize
                            self.connectionOrderModel.saveOrder(.uploadSize)
                            self.showBottomSheet = false
                        }) {
                            Text("Upload Size")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            self.orderMode = .downloadSpeed
                            self.connectionOrderModel.saveOrder(.downloadSpeed)
                            self.showBottomSheet = false
                        }) {
                            Text("Download Speed")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            self.orderMode = .uploadSpeed
                            self.connectionOrderModel.saveOrder(.uploadSpeed)
                            self.showBottomSheet = false
                        }) {
                            Text("Upload Speed")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            self.showBottomSheet = false
                        }) {
                            Text("Cancel")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                    }
                }.edgesIgnoringSafeArea(.all)
            }
            #endif
        }
        .onAppear {
            orderCancellable = self.connectionOrderModel.$orderMode.sink(receiveValue: { order in
                print("order change to \(order)")
                withAnimation {
                    self.orderMode = order
                }
            })
            keywordCancellable = self.connectionOrderModel.$searchKeyword
                .debounce(for: 0.5, scheduler: RunLoop.main)
                .removeDuplicates()
                .sink(receiveValue: { keyword in
                    print("keyword change to '\(keyword)'")
                    withAnimation {
                        self.keyword = keyword.lowercased()
                    }
                })
            currentServerIdxCancellable = serverModel.$currentServerIndex.sink(receiveValue: { idx in
                print("connectionsview current server index changed to \(idx)")
                if currentServerIdx >= 0 {
                    let server = serverModel.servers[currentServerIdx]
                    print("disconnect server \(server.host)")
                    connectionDataCancellable?.cancel()
                    server.websockets?.disconnect(.connections)
                    if !self.pause {
                        withAnimation {
                            self.connectionData = ConnectionData()
                        }
                    }
                }
                let server = serverModel.servers[idx]
                print("try connect server \(server.host)")
                server.websockets?.connect(.connections)
                connectionDataCancellable = server.websockets?.connectionWebSocket.$connectionData.sink(receiveValue: { connectionData in
                    if !self.pause {
                        self.connectionData = connectionData
                    }
                })
                currentServerIdx = idx
            })
            pauseCancellable = connectionOrderModel.$pause.sink(receiveValue: { pause in
                self.pause = pause
            })
        }
        .onDisappear {
            orderCancellable?.cancel()
            connectionDataCancellable?.cancel()
            currentServerIdxCancellable?.cancel()
            orderCancellable = nil
            connectionDataCancellable = nil
            currentServerIdxCancellable = nil
            if currentServerIdx > 0 {
                serverModel.servers[currentServerIdx].websockets?.disconnect(.connections)
            }
        }
        .navigationTitle("Connections")
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
}

#if DEBUG
struct ConnectionsView_Previews: PreviewProvider {
    static var connectionData = previewConnectionData
    static var previews: some View {
        let connectionOrderModel = ConnectionOrderModel()
        let serverModel = ServerModel()
        #if os(macOS)
        ConnectionsView(connectionData: connectionData)
            .environmentObject(serverModel)
            .environmentObject(connectionOrderModel)
        ConnectionsView(connectionData: connectionData)
            .environmentObject(serverModel)
            .environmentObject(connectionOrderModel)
//            .previewInterfaceOrientation(.landscapeLeft)
            .preferredColorScheme(.dark)
        #else
        Group {
            ConnectionsView(connectionData: connectionData)
                .environmentObject(serverModel)
                .environmentObject(connectionOrderModel)
            ConnectionsView(connectionData: connectionData)
                .environmentObject(serverModel)
                .environmentObject(connectionOrderModel)
//                .previewInterfaceOrientation(.landscapeLeft)
                .preferredColorScheme(.dark)
        }
        #endif
    }
}
#endif

