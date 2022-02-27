//
//  CreateServer.swift
//  claft
//
//  Created by zfu on 2021/12/1.
//

import SwiftUI
import Combine

struct Entry: Identifiable {
    var id = UUID()
    var title:String = ""
    var value:String = ""
    var image:String = ""
    var placeHolder:String = ""
    var isSecret: Bool = false
}
struct CreateServer: View {
    var entries:[Entry] = [
        Entry(title: "Host", image: "network", placeHolder: "Domain or IP"),
        Entry(title: "Port", image: "bolt.horizontal.circle", placeHolder: "9090"),
        Entry(title: "Secret", image: "lock.fill", placeHolder: "Optional", isSecret: true),
    ]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var serverModel:ServerModel
    @State var inputValue:[String] = ["", "9090", ""]
    @State var https:Bool = false
    var body: some View {
        NavigationView {
            List {
                ForEach(0..<entries.count) { idx in
//                ForEach(entries) { (entry, idx) in
                    HStack {
                        Image(systemName: entries[idx].image)
                        Text(entries[idx].title)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        if entries[idx].isSecret {
                            SecureField(entries[idx].placeHolder, text: $inputValue[idx])
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        } else {
                            TextField(entries[idx].placeHolder, text: $inputValue[idx])
                                .multilineTextAlignment(.leading)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                        }
                    }
                    .padding()
                }
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(https ? Color.green : Color.gray)
                    Text("https")
                        .frame(width: 80)
                        .multilineTextAlignment(.trailing)
                    Toggle("", isOn: $https)
                }.padding()
            }
            .navigationTitle("New Server")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                print("save")
                let secret:String? = inputValue[2].lengthOfBytes(using: .utf8) > 0 ? inputValue[2] : nil
                let server = Server(id: serverModel.servers.count, host: inputValue[0], port: inputValue[1], secret: secret, https: https)
                serverModel.servers.append(server)
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "square.and.arrow.down")
            }.disabled(inputValue[0].lengthOfBytes(using: .utf8) == 0))
        }
    }
}

struct CreateServer_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        return CreateServer().environmentObject(serverModel)
    }
}
