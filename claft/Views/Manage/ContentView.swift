//
//  ContentView.swift
//  claft
//
//  Created by zfu on 2021/11/29.
//

import SwiftUI
import Combine

struct MenuItem: Identifiable {
    var id = UUID()
    var title: String = "NA"
    var image: String = ""
}

struct ContentView: View {
//    @ObservedObject var serverModel:ServerModel = ServerModel()
    @State private var showSheet = false
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @State private var selection: Int? = -1
    #else
    @State private var selection: Int? = 0
    #endif
    @EnvironmentObject var serverModel:ServerModel
    var proxyData = previewProxyData
    var menus:[MenuItem] = [
        MenuItem(title: "OverView", image: "tablecells.fill"),
        MenuItem(title: "Proxies",  image: "network"),
        MenuItem(title: "Rules",    image: "list.bullet"),
        MenuItem(title: "Connections",    image: "point.3.filled.connected.trianglepath.dotted"),
        MenuItem(title: "Config",   image: "gearshape"),
        MenuItem(title: "Logs",     image: "terminal"),
    ]
    var body: some View {
        NavigationView {
            VStack {
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    ServerListView()
                }
                #endif
                if serverModel.servers.count > 0 {
                    List {
                        NavigationLink(destination: OverView(), tag: 0, selection: $selection) {
//                            Image(systemName: menus[0].image)
//                                .foregroundColor(self.selection == 0 ? .white : .blue)
//                            Text(menus[0].title)
//                                .padding()
                            Label(menus[0].title, systemImage: menus[0].image)
                                .padding()
                        }
                        NavigationLink(destination: ProxiesView(server: serverModel.servers[serverModel.currentServerIndex]), tag: 1, selection: $selection) {
//                            Image(systemName: menus[1].image)
//                                .foregroundColor(self.selection == 1 ? .white : .blue)
//                            Text(menus[1].title)
//                                .padding()
                            Label(menus[1].title, systemImage: menus[1].image)
                                .padding()
                        }
                        NavigationLink(destination: RuleView(), tag: 2, selection: $selection) {
//                            Image(systemName: menus[2].image)
//                                .foregroundColor(self.selection == 2 ? .white : .blue)
//                            Text(menus[2].title)
//                                .padding()
                            Label(menus[2].title, systemImage: menus[2].image)
                                .padding()
                        }
                        NavigationLink(destination: ConnectionsView(server: serverModel.servers[serverModel.currentServerIndex]), tag: 3, selection: $selection) {
//                            Image(systemName: menus[3].image)
//                                .foregroundColor(self.selection == 3 ? .white : .blue)
//                            Text(menus[3].title)
//                                .padding()
                            Label(menus[3].title, systemImage: menus[3].image)
                                .padding()
                        }
                        NavigationLink(destination: ConfigView(server: serverModel.servers[serverModel.currentServerIndex]), tag: 4, selection: $selection) {
//                            Image(systemName: menus[4].image)
//                                .foregroundColor(self.selection == 4 ? .white : .blue)
//                            Text(menus[4].title)
//                                .padding()
                            Label(menus[4].title, systemImage: menus[4].image)
                                .padding()
                        }
                        NavigationLink(destination: LogView(server: serverModel.servers[serverModel.currentServerIndex]), tag: 5, selection: $selection) {
//                            Image(systemName: menus[5].image)
//                                .foregroundColor(self.selection == 5 ? .white : .blue)
//                            Text(menus[5].title)
//                                .padding()
                            Label(menus[5].title, systemImage: menus[5].image)
                                .padding()
                        }
                    }
                }
            }
            .navigationTitle("Claft")
            .listStyle(SidebarListStyle())
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(trailing: Button(action: {
                showSheet.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
            }.sheet(isPresented: $showSheet) {
                ManageServerPanel(servers: $serverModel.servers)
            })
            #endif
        }
#if os(macOS)
        .toolbar {
//            ServerListView().environmentObject(serverModel)
            Button(action: {
                showSheet.toggle()
            }) {
                Label("ManageServers", systemImage: "slider.horizontal.3")
            }.sheet(isPresented: $showSheet) {
                ManageServerPanel(servers: $serverModel.servers)
                    .frame(width: 600, height: 360)
            }
        }
#endif
        .onAppear {
            print("onAppear")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        serverModel.servers = [
            Server(id: 0, host: "192.168.23.1", port: "9191", secret: "061x09bg33"),
            Server(id: 1, host: "127.0.0.1", port: "9090", https: true),
            Server(id: 2, host: "serverC", port: "9091", secret: "abc"),
            Server(id: 3, host: "serverD", port: "9092", secret: "def", https: true)
        ]
        return Group {
            ContentView().environmentObject(serverModel)
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            ContentView().environmentObject(serverModel)
                .preferredColorScheme(.dark)
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            ContentView().environmentObject(serverModel)
                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad mini (6th generation)"))
        }
    }
}
