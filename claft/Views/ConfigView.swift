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
    @ObservedObject var config: ConfigModel = ConfigModel()
    
    func onChanged() {
        print("onChanged")
    }
    
    var body: some View {
        VStack {
            List {
                Toggle("Allow LAN", isOn: $config.allowLan)
                VStack {
                    HStack {
                        Text("Mode")
                        Spacer()
                    }
                    Picker("Mode", selection: $config.mode) {
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
                    HStack {
                        Text("Log Level")
                        Spacer()
                    }
                    Picker("Log Level", selection: $config.logLevel) {
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
                        TextField("NA", text:$config.port)
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
                        TextField("NA", text:$config.httpPort)
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
                        TextField("NA", text:$config.socksPort)
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
                        TextField("NA", text:$config.mixedPort)
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
                        TextField("NA", text:$config.redirPort)
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
                        TextField("NA", text:$config.tproxyPort)
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
                        TextField("Test URL", text:$config.testURL)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .navigationTitle("Config")
        .onAppear {
            config.getDataFromServer(server)
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        let server = Server(id: 0, host: "127.0.0.1", port: "9090", secret: nil, https: false)
        ConfigView(server: server, config: ConfigModel())
    }
}
