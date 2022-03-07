//
//  ManageServerPanel.swift
//  claft
//
//  Created by zfu on 2021/12/1.
//

import SwiftUI
import Combine

struct ManageServerPanel: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showSheet = false
    @Binding var servers:[Server]
    var body: some View {
        print(Self._printChanges())
        return NavigationView {
            VStack {
                List() {
                    ForEach(servers, id: \.id) { server in
                        HStack {
                            if server.secret != nil {
                                if server.https {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(Color.green)
                                } else {
                                    Image(systemName: "lock.fill")
                                }
                            } else {
                                if server.https {
                                    Image(systemName: "lock")
                                        .foregroundColor(Color.green)
                                } else {
                                    Image(systemName: "lock")
                                }
                            }
                            Text("\(server.host)")
                                .padding()
                            Spacer()
                            Text("\(server.port)")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        #if os(iOS) || os(macOS)
                        .swipeActions {
                            Button(role:.destructive, action: {
                                print("delete")
                                servers = servers.filter({ server_ in
                                    server.id != server_.id
                                })
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        #endif
                    }
                }
            }
            .navigationTitle("Servers")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            },trailing: Button(action: {
                showSheet.toggle()
            }) {
                Image(systemName: "plus")
            })
            #endif
            .sheet(isPresented: $showSheet) {
                CreateServer()//.environmentObject(serverModel)
            }
        }
    }
}

struct ManageServerPanel_Previews: PreviewProvider {
    static var previews: some View {
        let servers = [
            Server(id: 0, host: "serverA", port: "9090"),
            Server(id: 1, host: "serverB", port: "9090", https: true),
            Server(id: 2, host: "serverC", port: "9091", secret: "abc"),
            Server(id: 3, host: "serverD", port: "9092", secret: "def", https: true)
        ]
        return ManageServerPanel(servers: .constant(servers))//.environmentObject(serverModel)
    }
}
