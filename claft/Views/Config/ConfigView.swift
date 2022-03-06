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
        guard configData.initialized else {
            return
        }
        if configModel.configData.allowLan != configData.allowLan {
            print("onChanged \(configData.initialized) allowLan \(configModel.configData.allowLan) => \(configData.allowLan)")
        }
        if configModel.configData.mode != configData.mode {
            print("onChanged \(configData.initialized) mode \(configModel.configData.mode) => \(configData.mode)")
        }
        if configModel.configData.logLevel != configData.logLevel {
            print("onChanged \(configData.initialized) logLevel \(configModel.configData.logLevel) => \(configData.logLevel)")
        }
        if configModel.configData.port != configData.port {
            print("onChanged \(configData.initialized) port \(configModel.configData.port) => \(configData.port)")
        }
        if configModel.configData.httpPort != configData.httpPort {
            print("onChanged \(configData.initialized) httpPort \(configModel.configData.httpPort) => \(configData.httpPort)")
        }
        if configModel.configData.socksPort != configData.socksPort {
            print("onChanged \(configData.initialized) socksPort \(configModel.configData.socksPort) => \(configData.socksPort)")
        }
        if configModel.configData.mixedPort != configData.mixedPort {
            print("onChanged \(configData.initialized) mixedPort \(configModel.configData.mixedPort) => \(configData.mixedPort)")
        }
        if configModel.configData.redirPort != configData.redirPort {
            print("onChanged \(configData.initialized) redirPort \(configModel.configData.redirPort) => \(configData.redirPort)")
        }
        if configModel.configData.tproxyPort != configData.tproxyPort {
            print("onChanged \(configData.initialized) tproxyPort \(configModel.configData.tproxyPort) => \(configData.tproxyPort)")
        }
        if configModel.configData.testURL != configData.testURL {
            print("onChanged \(configData.initialized) testURL \(configModel.configData.testURL) => \(configData.testURL)")
        }
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ServerListView()
                VStack {
                    if configData.initialized {
                    #if os(iOS)
                    Toggle("Allow LAN", isOn: $configData.allowLan)
                        .onChange(of: configData.allowLan) { value in
                            self.onChanged()
                        }
                    #else
                    HStack {
                        Text("Allow LAN")
                        Spacer()
                        Toggle("", isOn: $configData.allowLan)
                            .onChange(of: configData.allowLan) { value in
                                self.onChanged()
                            }
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
                        .onChange(of: configData.mode) { _ in
                            self.onChanged()
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
                            .onChange(of: configData.logLevel) { _ in
                                self.onChanged()
                            }
                    }
                    VStack {
                        HStack {
                            Text("Web Port")
                            Spacer()
                            TextField("NA", text:$configData.port)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: configData.port) { _ in
                                    self.onChanged()
                                }
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
                                .onChange(of: configData.httpPort) { _ in
                                    self.onChanged()
                                }
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
                                .onChange(of: configData.socksPort) { _ in
                                    self.onChanged()
                                }
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
                                .onChange(of: configData.mixedPort) { _ in
                                    self.onChanged()
                                }
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
                                .onChange(of: configData.redirPort) { _ in
                                    self.onChanged()
                                }
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
                                .onChange(of: configData.tproxyPort) { _ in
                                    self.onChanged()
                                }
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
                                .onChange(of: configData.testURL) { _ in
                                    self.onChanged()
                                }
                        }
                    }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Config")
        .onAppear {
            configModel.$configData.sink(receiveValue: { configData in
                var cd = configData
                cd.initialized = true
                self.configData = cd
            }).store(in: &cancelables)
            serverModel.$currentServerIndex.sink { idx in
                self.configData = ConfigDataModel()
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
