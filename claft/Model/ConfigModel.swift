//
//  Config.swift
//  claft
//
//  Created by zfu on 2021/12/2.
//

import Foundation
import Combine

struct ConfigData: Decodable {
    var allowLan:Bool?
    var authentication:[String]
    var bindAddress: String?
    var ipv6:Bool?
    var logLevel: String?
    var mode: String?
    var httpPort: Int?
    var mixedPort: Int?
    var port: Int?
    var redirPort: Int?
    var socksPort: Int?
    var tproxyPort: Int?

    enum CodingKeys: String, CodingKey {
        case allowLan = "allow-lan"
        case authentication = "authentication"
        case bindAddress = "bind-address"
        case ipv6 = "ipv6"
        case logLevel = "log-level"
        case httpPort = "http-port"
        case mixedPort = "mixed-port"
        case mode = "mode"
        case port = "port"
        case redirPort = "redir-port"
        case socksPort = "socks-port"
        case tproxyPort = "tproxy-port"
    }
}

class ConfigModel: ObservableObject {
    @Published var allowLan: Bool = false {
        didSet {
            print("allowLan Changed to \(allowLan)")
        }
    }
    @Published var authentication: [String] = []
    @Published var bindAddress: String = ""
    @Published var ipv6: Bool = false
    @Published var logLevel: Int = 0
    @Published var httpPort: String = ""
    @Published var mixedPort: String = ""
    @Published var mode: Int = 0
    @Published var port: String = ""
    @Published var redirPort: String = ""
    @Published var socksPort: String = ""
    @Published var tproxyPort: String = ""
    @Published var testURL: String = ""
    var finishInit: Bool = false

    private var cancellables = Set<AnyCancellable>()
    func getDataFromServer(_ server: Server) {
        let url = "http://\(server.host):\(server.port)/configs"
        finishInit = false
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        NetworkManager.shared.getData(url: url, type: ConfigData.self, headers: headers)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("error fetch from \(url) : \(err.localizedDescription)")
                case .finished:
                    print("network fetch from \(url) finished")
                }
            }
            receiveValue: { [weak self] config in
                self?.allowLan = config.allowLan ?? false
                self?.authentication = config.authentication
                self?.bindAddress = config.bindAddress ?? ""
                self?.ipv6 = config.ipv6 ?? false
                if let mode = config.mode {
                    if mode == "global" {
                        self?.mode = 0
                    } else if mode == "rule" {
                        self?.mode = 1
                    } else if mode == "script" {
                        self?.mode = 2
                    } else if mode == "direct" {
                        self?.mode = 3
                    }
                }
                if let logLevel = config.logLevel {
                    if logLevel == "info" {
                        self?.logLevel = 0
                    } else if logLevel == "warning" {
                        self?.logLevel = 1
                    } else if logLevel == "error" {
                        self?.logLevel = 2
                    } else if logLevel == "debug" {
                        self?.logLevel = 3
                    } else if logLevel == "silent" {
                        self?.logLevel = 4
                    }
                }
                if let httpPort = config.httpPort {
                    self?.httpPort = "\(httpPort)"
                } else {
                    self?.httpPort = ""
                }
                if let mixedPort = config.mixedPort {
                    self?.mixedPort = "\(mixedPort)"
                } else {
                    self?.mixedPort = ""
                }
                if let port = config.port {
                    self?.port = "\(port)"
                } else {
                    self?.port = ""
                }
                if let redirPort = config.redirPort {
                    self?.redirPort = "\(redirPort)"
                } else {
                    self?.redirPort = ""
                }
                if let socksPort = config.socksPort {
                    self?.socksPort = "\(socksPort)"
                } else {
                    self?.socksPort = ""
                }
                if let tproxyPort = config.tproxyPort {
                    self?.tproxyPort = "\(tproxyPort)"
                } else {
                    self?.tproxyPort = ""
                }
                print("update finish")
                self?.finishInit = true
            }
            .store(in: &cancellables)
    }
}
