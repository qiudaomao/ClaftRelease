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
    var server:Server
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack {
                    ForEach(connectionData.connections, id: \.id) { connectionItem in
                        ConnectionCardView(connectionItem: connectionItem)
                            .frame(width: rect.size.width - 40, height: 96)
                    }
                }
            }
            .background(Color("windowBackground"))
            Button(action: {
                print("button pressed")
            }) {
                let name:String = self.pause ? "play.circle.fill":"pause.circle.fill"
                Image(systemName: name)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .background(Circle().foregroundColor(.white).frame(width: 50, height: 50))
                    .position(x: rect.size.width - 56, y: rect.size.height - 50)
                    .gesture(TapGesture().onEnded({ () in
                        print("touched")
                        self.pause.toggle()
                    }))
//                    .shadow(color: .gray, radius: 0.2, x: 1, y: 1)
            }
        }
        .onAppear {
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
