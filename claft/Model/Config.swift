//
//  Config.swift
//  claft
//
//  Created by zfu on 2021/12/2.
//

import Foundation
import Combine

struct Config: Decodable {
    var allowLan:Bool?
    var authentication:[String]
    var bindAddress: String?
    var ipv6:Bool?
    var logLevel: String?
    var httpPort: String?
    var mixedPort: Int?
    var mode: String?
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
    private var cancellables = Set<AnyCancellable>()
    @Published var config = [Config]()
    
    func getData() {
        NetworkManager.shared.getData(url: "http://127.0.0.1:9090/configs", type: Config.self)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("Error \(err.localizedDescription)")
                case .finished:
                    print("finished")
                }
            }
            receiveValue: { [weak self] config in
                self?.config = [config]
            }
            .store(in: &cancellables)
    }
}
