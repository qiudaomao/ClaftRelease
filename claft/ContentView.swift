//
//  ContentView.swift
//  claft
//
//  Created by zfu on 2021/11/29.
//

import SwiftUI

struct Server: Hashable, Codable, Identifiable {
    var id: Int
    var host:String = ""
    var port:String = ""
    var up:Float = 0.0
    var down:Float = 0.0
    var secret:String? = nil
}

struct MenuItem: Identifiable {
    var id = UUID()
    var title: String = "NA"
    var image: String = ""
}

struct ContentView: View {
    @State private var showSheet = false
    var servers:[Server]
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
                        ForEach(servers) { (server) in
                            ServerCard(server: server)
                        }
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 0))
                    }
                }
                .frame(height: 60)
                List {
                    ForEach(menus) { (menu) in
                        NavigationLink(destination: ProxiesView()) {
                            Image(systemName: menu.image)
                                .foregroundColor(.blue)
                            Text(menu.title)
                                .padding()
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
                ManageServerPanel(servers: servers)
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(servers: [
                Server(id: 0, host: "serverA", port: "9090"),
                Server(id: 1, host: "serverB", port: "9091", secret: "abc"),
                Server(id: 2, host: "serverC", port: "9092")
                ])
                .previewInterfaceOrientation(.portrait)
                .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro"))
            ContentView(servers: [
                Server(id: 0, host: "serverA", port: "9090"),
                Server(id: 1, host: "serverB", port: "9091"),
                Server(id: 2, host: "serverC", port: "9092", secret: "password")
                ])
                .preferredColorScheme(.dark)
                .previewInterfaceOrientation(.portrait)
        }
    }
}
