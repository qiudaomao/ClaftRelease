//
//  ConfigView.swift
//  claft
//
//  Created by zfu on 2021/12/2.
//

import SwiftUI

struct ConfigView: View {
    var config: Config?
    @State var allowLan = true
    @State var mode = 0
    @State var logLevel = 0
    @State var port = ""
    @State var httpPort = ""
    @State var redirPort = ""
    @State var socksPort = ""
    @State var mixedPort = ""
    @State var tproxyPort = ""
    @State var testURL = ""
    
    init(config: Config) {
        self.config = config
        self._allowLan = State(wrappedValue: config.allowLan ?? false)
        if let mode = config.mode {
            self._mode = State(wrappedValue: Int(mode) ?? 0)
        }
        if let port = config.port {
            self._port = State(wrappedValue: "\(port)")
        }
        if let port = config.httpPort {
            self._httpPort = State(wrappedValue: "\(port)")
        }
        if let port = config.redirPort {
            self._redirPort = State(wrappedValue: "\(port)")
        }
        if let port = config.socksPort {
            self._socksPort = State(wrappedValue: "\(port)")
        }
        if let port = config.mixedPort {
            self._mixedPort = State(wrappedValue: "\(port)")
        }
        if let port = config.tproxyPort {
            self._tproxyPort = State(wrappedValue: "\(port)")
        }
        if let logLevel = config.logLevel {
            if logLevel == "info" {
                self._logLevel = State(wrappedValue: 0)
            } else if logLevel == "warning" {
                self._logLevel = State(wrappedValue: 1)
            } else if logLevel == "error" {
                self._logLevel = State(wrappedValue: 2)
            } else if logLevel == "debug" {
                self._logLevel = State(wrappedValue: 3)
            } else if logLevel == "silent" {
                self._logLevel = State(wrappedValue: 4)
            }
        }
    }
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Toggle("Allow LAN", isOn: $allowLan)
                    VStack {
                        HStack {
                            Text("Mode")
                            Spacer()
                        }
                        Picker("Mode", selection: $mode) {
                            Text("Global").tag(0)
                            Text("Rule").tag(1)
                            Text("Direct").tag(2)
                        }.pickerStyle(.segmented)
                    }
                    VStack {
                        HStack {
                            Text("Log Level")
                            Spacer()
                        }
                        Picker("Log Level", selection: $logLevel) {
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
                            TextField("NA", text:$port)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 17, design: .monospaced))
                        }
                    }
                    VStack {
                        HStack {
                            Text("HTTP Port")
                            Spacer()
                            TextField("NA", text:$httpPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 17, design: .monospaced))
                        }
                    }
                    VStack {
                        HStack {
                            Text("Socks Port")
                            Spacer()
                            TextField("NA", text:$socksPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 17, design: .monospaced))
                        }
                    }
                    VStack {
                        HStack {
                            Text("Mixed Port")
                            Spacer()
                            TextField("NA", text:$mixedPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 17, design: .monospaced))
                        }
                    }
                    VStack {
                        HStack {
                            Text("Redir Port")
                            Spacer()
                            TextField("NA", text:$redirPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 17, design: .monospaced))
                        }
                    }
                    VStack {
                        HStack {
                            Text("TProxy Port")
                            Spacer()
                            TextField("NA", text:$tproxyPort)
                                .frame(width: 120)
                                .multilineTextAlignment(.trailing)
                                .font(.system(size: 17, design: .monospaced))
                        }
                    }
                    VStack {
                        HStack {
                            Text("Test URL")
                            Spacer()
                            TextField("Test URL", text:$testURL)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            .navigationTitle("Config")
        }
    }
}

struct ConfigView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigView(config: previewConfigData)
    }
}
