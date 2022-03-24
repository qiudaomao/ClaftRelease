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

struct AllowLanConfig: Codable {
    var allowLan: Bool = false
    enum CodingKeys: String, CodingKey {
        case allowLan = "allow-lan"
    }
}

struct ModeConfig: Codable {
    var mode: String = "rule"
}

struct LogLevelConfig: Codable {
    var logLevel: String = "info"
    enum CodingKeys: String, CodingKey {
        case logLevel = "log-level"
    }
}

enum PatchConfigType {
    case allowLan
    case mode
    case logLevel
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
    var testURL: String = "http://www.gstatic.com/generate_204"
    var initialized: Bool = false
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
                    configData.httpPort = httpPort > 0 ? "\(httpPort)" : "NA".localized
                } else {
                    configData.httpPort = "NA".localized
                }
                if let mixedPort = config.mixedPort {
                    configData.mixedPort = mixedPort > 0 ? "\(mixedPort)" : "NA".localized
                } else {
                    configData.mixedPort = "NA".localized
                }
                if let port = config.port {
                    configData.port = port > 0 ? "\(port)" : "NA".localized
                } else {
                    configData.port = "NA".localized
                }
                if let redirPort = config.redirPort {
                    configData.redirPort = redirPort > 0 ? "\(redirPort)" : "NA".localized
                } else {
                    configData.redirPort = "NA".localized
                }
                if let socksPort = config.socksPort {
                    configData.socksPort = socksPort > 0 ? "\(socksPort)" : "NA".localized
                } else {
                    configData.socksPort = "NA".localized
                }
                if let tproxyPort = config.tproxyPort {
                    configData.tproxyPort = tproxyPort > 0 ? "\(tproxyPort)" : "NA".localized
                } else {
                    configData.tproxyPort = "NA".localized
                }
                print("update finish")
                self?.finishInit = true
                self?.configData = configData
            }
            .store(in: &cancellables)
    }
    
    func patchData<T: Encodable>(server: Server, value: T) -> Future<String?, Error>? {
        let url = "\(server.https ? "https":"http")://\(server.host):\(server.port)/configs"
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        return NetworkManager.shared.patchData(url: url, type: T.self, body: value, headers: headers)
    }
}
