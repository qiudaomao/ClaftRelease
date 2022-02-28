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
    @ObservedObject var serverModel:ServerModel = ServerModel()
    @State private var showSheet = false
    @State private var currentIndex: Int = 0
    var proxyData = previewProxyData
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
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(0..<serverModel.servers.count, id: \.self) { i in
                            ServerCard(server: serverModel.servers[i], trafficData: TrafficData(), selected: currentIndex == i)
                                .gesture(TapGesture().onEnded({ _ in
                                    currentIndex = i
                                }))
                        }
                        .onDelete(perform: { indexSet in
                            serverModel.servers.remove(atOffsets: indexSet)
                        })
                        .padding(EdgeInsets(top: 2, leading: 0, bottom: 2, trailing: 0))
                    }
                    #if os(iOS)
                    .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                    #else
                    .padding(EdgeInsets(top: 16, leading: 8, bottom: 2, trailing: 0))
                    #endif
                }
                #if os(iOS)
                .frame(height: 62)
                #else
                .frame(height: 78)
                #endif
                if serverModel.servers.count > 0 {
                    List {
                        NavigationLink(destination: PlaceHoldView()) {
                            Image(systemName: menus[0].image)
                                .foregroundColor(.blue)
                            Text(menus[0].title)
                                .padding()
                        }
                        NavigationLink(destination: ProxiesView(server: serverModel.servers[currentIndex])) {
                            Image(systemName: menus[1].image)
                                .foregroundColor(.blue)
                            Text(menus[1].title)
                                .padding()
                        }
                        NavigationLink(destination: PlaceHoldView()) {
                            Image(systemName: menus[2].image)
                                .foregroundColor(.blue)
                            Text(menus[2].title)
                                .padding()
                        }
                        NavigationLink(destination: ConnectionsView(server: serverModel.servers[currentIndex])) {
                            Image(systemName: menus[3].image)
                                .foregroundColor(.blue)
                            Text(menus[3].title)
                                .padding()
                        }
                        NavigationLink(destination: ConfigView(server: serverModel.servers[currentIndex])) {
                            Image(systemName: menus[4].image)
                                .foregroundColor(.blue)
                            Text(menus[4].title)
                                .padding()
                        }
                        NavigationLink(destination: PlaceHoldView()) {
                            Image(systemName: menus[5].image)
                                .foregroundColor(.blue)
                            Text(menus[5].title)
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
                ManageServerPanel(servers: $serverModel.servers).environmentObject(serverModel)
            })
            #else
            .toolbar {
                Spacer()
                Button(action: {
                    showSheet.toggle()
                }) {
                    Label("ManageServers", systemImage: "slider.horizontal.3")
                }.sheet(isPresented: $showSheet) {
                    ManageServerPanel(servers: $serverModel.servers).environmentObject(serverModel)
                        .frame(width: 600, height: 360)
                }
            }
            #endif
        }
        .onAppear {
            print("onAppear")
            serverModel.loadServers()
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
