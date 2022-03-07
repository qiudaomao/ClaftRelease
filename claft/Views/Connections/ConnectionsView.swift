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
    @State var rect:CGRect = CGRect()
    @State var pause:Bool = false
    @State var showBottomSheet = false
    @State var isOpenBottomSheet = false
    @State var currentServerIdx = -1
    @State var orderMode:ConnectionOrder = .none
    @ObservedObject var connectionOrderModel: ConnectionOrderModel = ConnectionOrderModel()
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject var serverModel:ServerModel
    
    var server:Server
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    LazyVStack {
                        ServerListView()
                        if (rect.size.width > 40) {
                            ForEach(connectionData.connections.sorted(by: { a, b in
                                if orderMode == .time {
                                    return a.start < b.start
                                } else if orderMode == .downloadSize {
                                    return a.download > b.download
                                } else if orderMode == .uploadSize {
                                    return a.upload > b.upload
                                }
                                return true
                            }), id: \.id) { connectionItem in
                                #if os(tvOS)
                                Button {
                                } label: {
                                    ConnectionCardView(connectionItem: connectionItem)
                                        .frame(width: rect.size.width - 40)
//                                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                                }
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                                .buttonStyle(CardButtonStyle())
                                #else
                                ConnectionCardView(connectionItem: connectionItem)
                                    .frame(width: (rect.size.width > 960) ? 960 - 40 : rect.size.width - 40)
                                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                                #endif
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 140, trailing: 0))
                }
                #if os(iOS)
//                .background(Color("windowBackground"))
                #endif
            }
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
            
            if showBottomSheet {
                BottomSheetView(isOpen: self.$isOpenBottomSheet, maxHeight: 540) {
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
                            self.showBottomSheet = false
                        }) {
                            Text("Cancel")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                    }
                }.edgesIgnoringSafeArea(.all)
            }
        }
        .onAppear {
            orderCancellable = self.connectionOrderModel.$orderMode.sink(receiveValue: { order in
                print("order changed to \(order)")
                self.orderMode = order
            })
            self.connectionOrderModel.loadOrder()
            currentServerIdxCancellable = serverModel.$currentServerIndex.sink(receiveValue: { idx in
                if currentServerIdx >= 0 {
                    if !self.pause {
                        self.connectionData = ConnectionData()
                    }
                    let server = serverModel.servers[currentServerIdx]
                    server.websockets?.disconnect(.connections)
                }
                let server = serverModel.servers[idx]
                server.websockets?.connect(.connections)
                connectionDataCancellable = server.websockets?.connectionWebSocket.$connectionData.sink(receiveValue: { connectionData in
                    if !self.pause {
                        self.connectionData = connectionData
                    }
                })
                currentServerIdx = idx
            })
        }
        .onDisappear {
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
        let server = Server(id: 0, host: "127.0.0.1", port: "9090", secret: nil, https: false)
        Group {
            ConnectionsView(connectionData: connectionData, server: server)
            ConnectionsView(connectionData: connectionData, server: server)
                .previewInterfaceOrientation(.landscapeLeft)
                .preferredColorScheme(.dark)
        }
    }
}
#endif

