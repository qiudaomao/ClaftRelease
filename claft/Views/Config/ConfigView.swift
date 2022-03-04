//
//  ConfigView.swift
//  claft
//
//  Created by zfu on 2021/12/2.
//

import SwiftUI
import Combine

struct ConfigView: View {
    var server: Server
    @ObservedObject var configModel: ConfigModel = ConfigModel()
    @EnvironmentObject var serverModel:ServerModel
    @State private var cancelables = Set<AnyCancellable>()
    @State var configData: ConfigDataModel = ConfigDataModel()
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    
    func onChanged() {
        print("onChanged")
    }
    
    var body: some View {
        VStack {
            ScrollView {
                #if os(iOS)
                if horizontalSizeClass == .compact {
                    ServerListView().environmentObject(serverModel)
                }
                #else
                ServerListView().environmentObject(serverModel)
                #endif
                VStack {
                    #if os(iOS)
                    Toggle("Allow LAN", isOn: $configData.allowLan)
                    #else
                    HStack {
                        Text("Allow LAN")
                        Spacer()
                        Toggle("", isOn: $configData.allowLan)
                    }
                    #endif
                    VStack {
                        #if os(iOS)
                        HStack {
                            Text("Mode")
                            Spacer()
                        }
                        #endif
                        Picker("Mode", selection: $configData.mode) {
                            Text("Global").tag(0)
                            Text("Rule").tag(1)
                            Text("Script").tag(2)
                            Text("Direct").tag(3)
                        }
                        .pickerStyle(.segmented)
                        .onSubmit {
                            onChanged()
                        }
                    }
                    VStack {
                        #if os(iOS)
                        HStack {
                            Text("Log Level")
                            Spacer()
                        }
                        #endif
                        Picker("Log Level", selection: $configData.logLevel) {
                            Text("info").tag(0)
                            Text("warning").tag(1)
                            Text("error").tag(2)
                            Text("debug").tag(3)
                            Text("silent").tag(4)
                        }.pickerStyle(.segmented)
                    }
                    VStack {
                        HStack {
                            Text("Web Port")
                            Spacer()
                            TextField("NA", text:$configData.port)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                            #if os(iOS)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 17, design: .monospaced))
                            #endif
                        }
                    }
                    VStack {
                        HStack {
                            Text("HTTP Port")
                            Spacer()
                            TextField("NA", text:$configData.httpPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                            #if os(iOS)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 17, design: .monospaced))
                            #endif
                        }
                    }
                    VStack {
                        HStack {
                            Text("Socks Port")
                            Spacer()
                            TextField("NA", text:$configData.socksPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                            #if os(iOS)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 17, design: .monospaced))
                            #endif
                        }
                    }
                    VStack {
                        HStack {
                            Text("Mixed Port")
                            Spacer()
                            TextField("NA", text:$configData.mixedPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                            #if os(iOS)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 17, design: .monospaced))
                            #endif
                        }
                    }
                    VStack {
                        HStack {
                            Text("Redir Port")
                            Spacer()
                            TextField("NA", text:$configData.redirPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                            #if os(iOS)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 17, design: .monospaced))
                            #endif
                        }
                    }
                    VStack {
                        HStack {
                            Text("TProxy Port")
                            Spacer()
                            TextField("NA", text:$configData.tproxyPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                            #if os(iOS)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 17, design: .monospaced))
                            #endif
                        }
                    }
                    VStack {
                        HStack {
                            Text("Test URL")
                            Spacer()
                            TextField("Test URL", text:$configData.testURL)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Config")
        .onAppear {
            self.configData = configModel.configData
            configModel.$configData.sink(receiveValue: { configData in
                self.configData = configData
            }).store(in: &cancelables)
            serverModel.$currentServerIndex.sink { idx in
                let server = serverModel.servers[idx]
                configModel.getDataFromServer(server)
            }.store(in: &cancelables)
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let server = Server(id: 0, host: "127.0.0.1", port: "9090", secret: nil, https: false)
        ConfigView(server: server, configModel: ConfigModel()).environmentObject(ServerModel())
    }
}
