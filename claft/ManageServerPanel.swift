//
//  ManageServerPanel.swift
//  claft
//
//  Created by zfu on 2021/12/1.
//

import SwiftUI

struct ManageServerPanel: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var servers:[Server] = []
    @State private var showSheet = false
    var body: some View {
        NavigationView {
            VStack {
                List() {
                    ForEach(servers) { server in
                        HStack {
                            if server.secret != nil {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color.green)
                            } else {
                                Image(systemName: "lock")
                            }
                            Text("\(server.host)")
                                .padding()
                            Spacer()
                            Text("\(server.port)")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                        .swipeActions {
                            Button(role:.destructive, action: {
                                print("delete")
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Servers")
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
            .sheet(isPresented: $showSheet) {
                CreateServer()
            }
        }
    }
}

struct ManageServerPanel_Previews: PreviewProvider {
    static var previews: some View {
        ManageServerPanel(servers: [
            Server(id: 0, host: "serverA", port: "9090"),
            Server(id: 1, host: "serverB", port: "9091", secret: "abc"),
            Server(id: 2, host: "serverC", port: "9092")
        ])
    }
}
