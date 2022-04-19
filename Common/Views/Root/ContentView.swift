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
    #elseif os(tvOS)
    @State private var selection: Int? = -1
    #else
    @State private var selection: Int? = 0
    @State private var cancellables:Set<AnyCancellable> = Set<AnyCancellable>()
    @State var firstChange: Bool = true
    #endif
    @EnvironmentObject var serverModel:ServerModel
    @EnvironmentObject var connectionOrderModel: ConnectionOrderModel
    var menus:[MenuItem] = [
        MenuItem(title: "OverView".localized,
                 image: "tablecells.fill"),
        MenuItem(title: "Proxies".localized,
                 image: "network"),
        MenuItem(title: "Rules".localized,
                 image: "list.bullet"),
        MenuItem(title: "Connections".localized,
                 image: "point.3.filled.connected.trianglepath.dotted"),
        MenuItem(title: "Config".localized,
                 image: "gearshape"),
        MenuItem(title: "Logs".localized,
                 image: "terminal"),
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
                            Label(menus[0].title, systemImage: menus[0].image)
                                .padding()
                        }
                        NavigationLink(destination: ProxiesView(), tag: 1, selection: $selection) {
                            Label(menus[1].title, systemImage: menus[1].image)
                                .padding()
                        }
                        NavigationLink(destination: RuleView(), tag: 2, selection: $selection) {
                            Label(menus[2].title, systemImage: menus[2].image)
                                .padding()
                        }
                        #if os(macOS)
                        NavigationLink(destination: ConnectionsView(), tag: 3, selection: $selection) {
                            Label(menus[3].title, systemImage: menus[3].image)
                                .padding()
                        }
                        #else
                        NavigationLink(destination: ConnectionsView(), tag: 3, selection: $selection) {
                            Label(menus[3].title, systemImage: menus[3].image)
                                .padding()
                        }
                        #endif
                        NavigationLink(destination: ConfigView(server: serverModel.currentServer), tag: 4, selection: $selection) {
                            Label(menus[4].title, systemImage: menus[4].image)
                                .padding()
                        }
                        NavigationLink(destination: LogView(), tag: 5, selection: $selection) {
                            Label(menus[5].title, systemImage: menus[5].image)
                                .padding()
                        }
                    }
                } else {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Label("Server", systemImage: "plus.circle")
                    }

                }
            }
            .navigationTitle("Claft")
            #if !os(tvOS)
            .listStyle(SidebarListStyle())
            #endif
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(trailing: Button(action: {
                showSheet.toggle()
            }) {
                Image(systemName: "slider.horizontal.3")
            }.sheet(isPresented: $showSheet) {
                ManageServerPanel()
            })
            #endif
        }
#if os(macOS)
        .toolbar {
            if self.selection == 2 || self.selection == 5 {
                ZStack {
                        TextField("Search", text: $connectionOrderModel.searchKeyword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color("textFieldBackground"))
                            .frame(width: 120, height: 28)
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                            .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        Spacer()
                    })
                }
            } else if self.selection == 3 {
                ZStack {
                        TextField("Search", text: $connectionOrderModel.searchKeyword)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(7)
                            .padding(.horizontal, 25)
                            .background(Color("textFieldBackground"))
                            .frame(width: 120, height: 28)
                            .cornerRadius(8)
                            .padding(.horizontal, 10)
                            .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16)
                        Spacer()
                    })
                }
                Picker(selection: $connectionOrderModel.orderMode, label: Text("Sort By")) {
                    Text("Default").tag(ConnectionOrder.none)
                    Text("Time").tag(ConnectionOrder.time)
                    Text("Download Size").tag(ConnectionOrder.downloadSize)
                    Text("Upload Size").tag(ConnectionOrder.uploadSize)
                    Text("Download Speed").tag(ConnectionOrder.downloadSpeed)
                    Text("Upload Speed").tag(ConnectionOrder.uploadSpeed)
                }
                Button(action: {
                    connectionOrderModel.pause.toggle()
                }) {
                    Image(systemName: connectionOrderModel.pause ? "play.fill" : "pause.fill")
                }
            }
            Button(action: {
                showSheet.toggle()
            }) {
                Label("ManageServers", systemImage: "slider.horizontal.3")
            }.sheet(isPresented: $showSheet) {
                ManageServerPanel()
                    .frame(width: 480, height: 360)
            }
        }
#endif
        .onAppear {
            print("onAppear")
            #if os(iOS)
            if horizontalSizeClass != .compact {
                selection = 0
            }
            #endif
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        serverModel.servers = [
            Server(id: UUID(), host: "192.168.23.1", port: "9191", secret: "061x09bg33"),
            Server(id: UUID(), host: "127.0.0.1", port: "9090", https: true),
            Server(id: UUID(), host: "serverC", port: "9091", secret: "abc"),
            Server(id: UUID(), host: "serverD", port: "9092", secret: "def", https: true)
        ]
        return Group {
            ContentView().environmentObject(serverModel)
//                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            ContentView().environmentObject(serverModel)
                .preferredColorScheme(.dark)
//                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            ContentView().environmentObject(serverModel)
//                .previewInterfaceOrientation(.landscapeLeft)
                .previewDevice(PreviewDevice(rawValue: "iPad mini (6th generation)"))
        }
    }
}
