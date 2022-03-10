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
    @State var changeAllowLanCancellable: AnyCancellable? = nil
    @State var changeModeCancellable: AnyCancellable? = nil
    @State var changeLogLevelCancellable: AnyCancellable? = nil
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    
    func onChanged() {
        guard configData.initialized else {
            return
        }
        if configModel.configData.allowLan != configData.allowLan {
            print("onChanged \(configData.initialized) allowLan \(configModel.configData.allowLan) => \(configData.allowLan)")
            //patch allow lan
            let data = AllowLanConfig(allowLan: configData.allowLan)
            changeAllowLanCancellable = configModel.patchData(server: server, value: data)?.sink(receiveCompletion: { error in
                print("error \(error)")
                configModel.getDataFromServer(server)
            }, receiveValue: { _ in
            })
        }
        if configModel.configData.mode != configData.mode {
            print("onChanged \(configData.initialized) mode \(configModel.configData.mode) => \(configData.mode)")
            /*
            if let mode = config.mode {
                if mode == "global" {
                    configData.mode = 0
                } else if mode == "rule" {
                    configData.mode = 1
                } else if mode == "script" {
                    configData.mode = 2
                } else if mode == "direct" {
                    configData.mode = 3
                }
            }
            if let logLevel = config.logLevel {
                if logLevel == "info" {
                    configData.logLevel = 0
                } else if logLevel == "warning" {
                    configData.logLevel = 1
                } else if logLevel == "error" {
                    configData.logLevel = 2
                } else if logLevel == "debug" {
                    configData.logLevel = 3
                } else if logLevel == "silent" {
                    configData.logLevel = 4
                }
            }
             */
            let strs = ["global", "rule", "script", "direct"]
            let data = ModeConfig(mode: strs[configData.mode])
            changeModeCancellable = configModel.patchData(server: server, value: data)?.sink(receiveCompletion: { error in
                print("error \(error)")
                configModel.getDataFromServer(server)
            }, receiveValue: { _ in
            })
        }
        if configModel.configData.logLevel != configData.logLevel {
            print("onChanged \(configData.initialized) logLevel \(configModel.configData.logLevel) => \(configData.logLevel)")
            let strs = ["info", "warning", "error", "debug", "silent"]
            let data = LogLevelConfig(logLevel: strs[configData.logLevel])
            changeLogLevelCancellable = configModel.patchData(server: server, value: data)?.sink(receiveCompletion: { error in
                print("error \(error)")
                configModel.getDataFromServer(server)
            }, receiveValue: { _ in
            })
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
                                Text("\(configData.port)")
                                    .foregroundColor(.secondary)
//                                    .frame(width: 120)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: configData.port) { _ in
                                        self.onChanged()
                                    }
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 17, design: .monospaced))
                                #endif
                            }
                        }.padding([.top], 5)
                        VStack {
                            HStack {
                                Text("HTTP Port")
                                Spacer()
                                Text("\(configData.httpPort)")
//                                    .frame(width: 120)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                                    .onChange(of: configData.httpPort) { _ in
                                        self.onChanged()
                                    }
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 17, design: .monospaced))
                                #endif
                            }
                        }.padding([.top], 5)
                        VStack {
                            HStack {
                                Text("Socks Port")
                                Spacer()
                                Text("\(configData.socksPort)")
//                                    .frame(width: 120)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: configData.socksPort) { _ in
                                        self.onChanged()
                                    }
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 17, design: .monospaced))
                                #endif
                            }
                        }.padding([.top], 5)
                        VStack {
                            HStack {
                                Text("Mixed Port")
                                Spacer()
                                Text("\(configData.mixedPort)")
//                                    .frame(width: 120)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: configData.mixedPort) { _ in
                                        self.onChanged()
                                    }
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 17, design: .monospaced))
                                #endif
                            }
                        }.padding([.top], 5)
                        VStack {
                            HStack {
                                Text("Redir Port")
                                Spacer()
                                Text("\(configData.redirPort)")
//                                    .frame(width: 120)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: configData.redirPort) { _ in
                                        self.onChanged()
                                    }
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 17, design: .monospaced))
                                #endif
                            }
                        }.padding([.top], 5)
                        VStack {
                            HStack {
                                Text("TProxy Port")
                                Spacer()
                                Text("\(configData.tproxyPort)")
//                                    .frame(width: 120)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.trailing)
                                    .onChange(of: configData.tproxyPort) { _ in
                                        self.onChanged()
                                    }
                                #if os(iOS)
                                    .keyboardType(.decimalPad)
                                    .font(.system(size: 17, design: .monospaced))
                                #endif
                            }
                        }.padding([.top], 5)
                        VStack {
                            HStack {
                                Text("Test URL")
                                Spacer()
                                Text("\(configData.testURL)")
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(.secondary)
                                    .onChange(of: configData.testURL) { _ in
                                        self.onChanged()
                                    }
                            }
                        }.padding([.top], 5)
                    }
                }
                .frame(maxWidth: 480)
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
        let server = Server(id: UUID(), host: "127.0.0.1", port: "9090", secret: nil, https: false)
        ConfigView(server: server, configModel: ConfigModel()).environmentObject(ServerModel())
    }
}
