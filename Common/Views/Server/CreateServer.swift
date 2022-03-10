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

enum CreateServerFocus: Int, Hashable {
    case host = 0
    case port = 1
    case secret = 2
}

#if os(iOS) || os(tvOS)
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
    @FocusState var focus: CreateServerFocus?
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
                            #if os(iOS)
                                .autocapitalization(.none)
                            #endif
                                .disableAutocorrection(true)
                                .focused($focus, equals: CreateServerFocus(rawValue: idx))
                        } else {
                            TextField(entries[idx].placeHolder, text: $inputValue[idx])
                                .multilineTextAlignment(.leading)
                            #if os(iOS)
                                .autocapitalization(.none)
                            #endif
                                .disableAutocorrection(true)
                                .focused($focus, equals: CreateServerFocus(rawValue: idx))
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
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                print("save")
                let secret:String? = inputValue[2].lengthOfBytes(using: .utf8) > 0 ? inputValue[2] : nil
                var server = Server(id: serverModel.servers.count, host: inputValue[0], port: inputValue[1], secret: secret, https: https)
                serverModel.servers.append(server)
                serverModel.connectServer(serverModel.servers.count-1)
                serverModel.saveServers()
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "square.and.arrow.down")
            }.disabled(inputValue[0].lengthOfBytes(using: .utf8) == 0))
            #endif
        }
    }
}
#else
struct CreateServer: View {
    var entries:[Entry] = [
        Entry(title: "Host".localized, image: "network", placeHolder: "Domain or IP".localized),
        Entry(title: "Port".localized, image: "bolt.horizontal.circle", placeHolder: "9090"),
        Entry(title: "Secret".localized, image: "lock.fill", placeHolder: "Optional".localized, isSecret: true),
    ]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var serverModel:ServerModel
    @State var inputValue:[String] = ["", "9090", ""]
    @State var https:Bool = false
    @FocusState var focus: CreateServerFocus?
    var body: some View {
        VStack {
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
                    let secret:String? = inputValue[2].lengthOfBytes(using: .utf8) > 0 ? inputValue[2] : nil
                    let server = Server(id: UUID(), host: inputValue[0], port: inputValue[1], secret: secret, https: https)
                    serverModel.servers.append(server)
                    serverModel.connectServer(serverModel.servers.count-1)
                    serverModel.saveServers()
                    self.presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
                .disabled(inputValue[0].lengthOfBytes(using: .utf8) == 0)
            }
            .padding()
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
                                .focused($focus, equals: CreateServerFocus(rawValue: idx))
                                .multilineTextAlignment(.leading)
                                .disableAutocorrection(true)
                                .frame(width: 120)
                        } else {
                            TextField(entries[idx].placeHolder, text: $inputValue[idx])
                                .focused($focus, equals: CreateServerFocus(rawValue: idx))
                                .multilineTextAlignment(.leading)
                                .disableAutocorrection(true)
                                .frame(width: 120)
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
        }
        .onAppear {
            focus = .host
        }
    }
}
#endif

struct CreateServer_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        return CreateServer().environmentObject(serverModel)
    }
}
