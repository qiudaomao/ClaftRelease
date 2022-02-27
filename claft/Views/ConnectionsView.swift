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
    @State var rect:CGRect = CGRect()
    @State var pause:Bool = false
    @State var showBottomSheet = false
    @State var isOpenBottomSheet = false
    @ObservedObject var connectionOrderModel: ConnectionOrderModel = ConnectionOrderModel()
    var server:Server
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    ForEach(connectionData.connections.sorted(by: { a, b in
                        if connectionOrderModel.orderMode == .time {
                            return a.start < b.start
                        } else if connectionOrderModel.orderMode == .downloadSize {
                            return a.download > b.download
                        } else if connectionOrderModel.orderMode == .uploadSize {
                            return a.upload > b.upload
                        }
                        return true
                    }), id: \.id) { connectionItem in
                        ConnectionCardView(connectionItem: connectionItem)
                            .frame(width: rect.size.width - 40, height: 96)
                    }
                }
            }
            .background(Color("windowBackground"))
            let name:String = self.pause ? "play.circle.fill":"pause.circle.fill"
            Image(systemName: name)
                .resizable()
                .frame(width: 60, height: 60)
                .background(Circle().foregroundColor(.white).frame(width: 50, height: 50))
                .foregroundColor(.blue)
                .position(x: rect.size.width - 56, y: rect.size.height - 50)
                .gesture(TapGesture().onEnded({ () in
                    print("touched")
                    self.pause.toggle()
                }))
            Image(systemName: "arrow.clockwise.circle.fill")
                .resizable()
                .frame(width: 60, height: 60)
                .background(Circle().foregroundColor(.white).frame(width: 50, height: 50))
                .foregroundColor(.blue)
                .position(x: rect.size.width - 56, y: rect.size.height - 130)
                .gesture(TapGesture().onEnded({ () in
                    print("touched reorder")
                    self.showBottomSheet.toggle()
                }))
            
            if showBottomSheet {
                BottomSheetView(isOpen: self.$isOpenBottomSheet, maxHeight: 540) {
                    VStack {
                        Text("Sort By")
                            .font(.system(size: 23))
                            .padding()
                        Button(action: {
                            print("yes")
                            self.connectionOrderModel.orderMode = .none
                            self.connectionOrderModel.saveOrder()
                            self.showBottomSheet = false
                        }) {
                            Text("Default")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            print("yes")
                            self.connectionOrderModel.orderMode = .time
                            self.connectionOrderModel.saveOrder()
                            self.showBottomSheet = false
                        }) {
                            Text("Start Time")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            print("yes")
                            self.connectionOrderModel.orderMode = .downloadSize
                            self.connectionOrderModel.saveOrder()
                            self.showBottomSheet = false
                        }) {
                            Text("Download Size")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            print("yes")
                            self.connectionOrderModel.orderMode = .uploadSize
                            self.connectionOrderModel.saveOrder()
                            self.showBottomSheet = false
                        }) {
                            Text("Upload Size")
                        }
                        .padding(EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0))
                        Button(action: {
                            print("yes")
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
            self.connectionOrderModel.loadOrder()
            server.websockets?.connect(.connections)
            connectionDataCancellable = server.websockets?.connectionWebSocket.$connectionData.sink(receiveValue: { connectionData in
                if !self.pause {
                    self.connectionData = connectionData
                }
            })
        }
        .onDisappear {
            connectionDataCancellable = nil
            server.websockets?.disconnect(.connections)
        }
        .navigationTitle("Connections")
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
}

struct ConnectionsView_Previews: PreviewProvider {
    static var connectionData = previewConnectionData
    static var previews: some View {
        let server = Server(id: 0, host: "127.0.0.1", port: "9090", secret: nil, https: false)
        Group {
            ConnectionsView(connectionData: connectionData, server: server)
            ConnectionsView(connectionData: connectionData, server: server)
                .preferredColorScheme(.dark)
        }
    }
}
