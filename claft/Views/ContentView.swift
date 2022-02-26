//
//  ContentView.swift
//  claft
//
//  Created by zfu on 2021/11/29.
//

import SwiftUI
import Combine

enum ConnectStatus: Int, Codable {
    case none
    case connectting
    case connected
    case failed
}

struct Server: Hashable, Codable, Identifiable {
    var id: Int
    var host:String = ""
    var port:String = ""
    var up:Float = 0.0
    var down:Float = 0.0
    var secret:String? = nil
    var https:Bool = false
    var connectStatus: ConnectStatus = .none
}

struct MenuItem: Identifiable {
    var id = UUID()
    var title: String = "NA"
    var image: String = ""
}

class ServerModel: ObservableObject {
    @Published var servers:[Server] = [
        Server(id: 0, host: "serverA", port: "9090"),
        Server(id: 1, host: "serverB", port: "9090", https: true),
        Server(id: 2, host: "serverC", port: "9091", secret: "abc"),
        Server(id: 3, host: "serverD", port: "9092", secret: "def", https: true)
    ]
}

struct ContentView: View {
    @ObservedObject var serverModel:ServerModel = ServerModel()
    @State private var showSheet = false
    @State private var currentIndex: Int = 0
//    var servers:[Server]
    var menus:[MenuItem] = [
        MenuItem(title: "OverView", image: "tablecells.fill"),
        MenuItem(title: "Proxies",  image: "network"),
        MenuItem(title: "Rules",    image: "list.bullet"),
        MenuItem(title: "Conns",    image: "point.3.filled.connected.trianglepath.dotted"),
        MenuItem(title: "Config",   image: "gearshape"),
        MenuItem(title: "Logs",     image: "terminal"),
    ]
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal) {
                    LazyHStack {
                        ForEach(0..<serverModel.servers.count, id: \.self) { i in
//                        ForEach(serverModel.servers) { (server) in
                            ServerCard(server: serverModel.servers[i], selected: currentIndex == i)
                                .gesture(TapGesture().onEnded({ _ in
                                    currentIndex = i
                                }))
                        }
                        .onDelete(perform: { indexSet in
                            serverModel.servers.remove(atOffsets: indexSet)
                        })
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 0))
                    }
                }
                .frame(height: 60)
                List {
                    ForEach(0..<menus.count) { idx in
//                    ForEach(menus) { (menu) in
                        switch idx {
                        case 0:
                            NavigationLink(destination: ConfigView(config: previewConfigData)) {
                                Image(systemName: menus[idx].image)
                                    .foregroundColor(.blue)
                                Text(menus[idx].title)
                                    .padding()
                            }
                        case 1:
                            NavigationLink(destination: ProxiesView()) {
                                Image(systemName: menus[idx].image)
                                    .foregroundColor(.blue)
                                Text(menus[idx].title)
                                    .padding()
                            }
                        default:
                            NavigationLink(destination: ProxiesView()) {
                                Image(systemName: menus[idx].image)
                                    .foregroundColor(.blue)
                                Text(menus[idx].title)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Claft")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(trailing: Button(action: {
                showSheet.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
            }.sheet(isPresented: $showSheet) {
                ManageServerPanel().environmentObject(serverModel)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        serverModel.servers = [
            Server(id: 0, host: "serverA", port: "9090"),
            Server(id: 1, host: "serverB", port: "9090", https: true),
            Server(id: 2, host: "serverC", port: "9091", secret: "abc"),
            Server(id: 3, host: "serverD", port: "9092", secret: "def", https: true)
        ]
        return Group {
            ContentView(serverModel: serverModel)
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            ContentView(serverModel: serverModel)
                .preferredColorScheme(.dark)
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            ContentView(serverModel: serverModel)
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad mini (6th generation)"))
        }
    }
}