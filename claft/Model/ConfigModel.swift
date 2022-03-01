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

struct ConfigDataModel {
    var allowLan: Bool = false
    var authentication: [String] = []
    var bindAddress: String = ""
    var ipv6: Bool = false
    var logLevel: Int = 0
    var httpPort: String = ""
    var mixedPort: String = ""
    var mode: Int = 0
    var port: String = ""
    var redirPort: String = ""
    var socksPort: String = ""
    var tproxyPort: String = ""
    var testURL: String = ""
}

class ConfigModel: ObservableObject {
    @Published var configData: ConfigDataModel = ConfigDataModel()
    @Published var allowLan: Bool = false {
        didSet {
            print("allowLan Changed to \(allowLan)")
        }
    }
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
                var configData = ConfigDataModel()
                configData.allowLan = config.allowLan ?? false
                configData.authentication = config.authentication
                configData.bindAddress = config.bindAddress ?? ""
                configData.ipv6 = config.ipv6 ?? false
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
                if let httpPort = config.httpPort {
                    configData.httpPort = "\(httpPort)"
                } else {
                    configData.httpPort = ""
                }
                if let mixedPort = config.mixedPort {
                    configData.mixedPort = "\(mixedPort)"
                } else {
                    configData.mixedPort = ""
                }
                if let port = config.port {
                    configData.port = "\(port)"
                } else {
                    configData.port = ""
                }
                if let redirPort = config.redirPort {
                    configData.redirPort = "\(redirPort)"
                } else {
                    configData.redirPort = ""
                }
                if let socksPort = config.socksPort {
                    configData.socksPort = "\(socksPort)"
                } else {
                    configData.socksPort = ""
                }
                if let tproxyPort = config.tproxyPort {
                    configData.tproxyPort = "\(tproxyPort)"
                } else {
                    configData.tproxyPort = ""
                }
                print("update finish")
                self?.finishInit = true
                self?.configData = configData
            }
            .store(in: &cancellables)
    }
}
