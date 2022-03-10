//
//  ManageServerPanel.swift
//  claft
//
//  Created by zfu on 2021/12/1.
//

import SwiftUI
import Combine

#if os(iOS) || os(tvOS)
struct ManageServerPanel: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showSheet = false
    @EnvironmentObject var serverModel:ServerModel
//    @Binding var servers:[Server]
    var body: some View {
        return NavigationView {
            VStack {
                List() {
                    ForEach(serverModel.servers, id: \.id) { server in
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
                                serverModel.saveServers()
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
                CreateServer()
            }
        }
    }
}
#elseif os(macOS)
struct ManageServerPanel: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showSheet = false
//    @Binding var servers:[Server]
    @EnvironmentObject var serverModel:ServerModel
    @State var rect:CGRect = .zero
    var body: some View {
        return VStack {
            HStack {
                Button {
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward")
                }
                Spacer()
                Text("Servers")
                    .font(.headline)
                Spacer()
                Button {
                    self.showSheet.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            .padding()
            List() {
                ForEach(serverModel.servers, id: \.id) { server in
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
                        Button {
                            print("delete")
                            serverModel.servers = serverModel.servers.filter({ server_ in
                                server.id != server_.id
                            })
                            serverModel.saveServers()
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
        }
//        .frame(width: 600, height: 480)
        .sheet(isPresented: $showSheet) {
            CreateServer()//.environmentObject(serverModel)
                .frame(width: 400, height: 320)
        }
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
}
#endif

struct ManageServerPanel_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        return ManageServerPanel().environmentObject(serverModel)
    }
}
