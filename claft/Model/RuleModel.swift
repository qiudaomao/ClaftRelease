//
//  RuleModel.swift
//  claft
//
//  Created by zfu on 2022/3/1.
//

import Foundation
import Combine

struct RuleData: Codable, Hashable {
    var payload: String = ""
    var proxy: String = ""
    var type: String = ""
}

struct Rule: Codable, Hashable {
    var rules: [RuleData] = []
}

struct RuleItem {
    var payload: String = ""
    var proxy: String = ""
    var type: String = ""
    var uuid: UUID = UUID()
}

class RuleModel: ObservableObject {
    @Published var rules:[RuleItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    func loadRule(_ server:Server) {
        let url = "http://\(server.host):\(server.port)/rules"
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        NetworkManager.shared.getData(url: url, type: Rule.self, headers: headers)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("error fetch from \(url) : \(err.localizedDescription)")
                case .finished:
                    print("network fetch from \(url) finished")
                }
            }
            receiveValue: { [weak self] rule in
                self?.rules = rule.rules.map({ item in
                    return RuleItem(payload: item.payload, proxy: item.proxy, type: item.type, uuid: UUID())
                })
            }
            .store(in: &cancellables)
    }
}
