//
//  ProxyModel.swift
//  claft
//
//  Created by zfu on 2022/2/27.
//

import Foundation
import Combine

struct ProxyHistoryData: Codable {
    var time: String = ""
    var delay: Int = 0
}

struct ProxyItemData: Codable {
    var all: [String] = []/* proxy didn't have this, only selector/URLTest has it */
    var history: [ProxyHistoryData] = []
    var name: String = ""
    var now: String = ""
    var type: String = ""
    var udp: Bool = false
    var uuid: UUID = UUID()
    var expanded: Bool = false

    init() {
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let all = try container.decodeIfPresent([String].self, forKey: .all) {
            self.all = all
        } else {
            self.all = []
        }
        if let history = try container.decodeIfPresent([ProxyHistoryData].self, forKey: .history) {
            self.history = history
        } else {
            self.history = []
        }
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        now = try container.decodeIfPresent(String.self, forKey: .now) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        udp = try container.decodeIfPresent(Bool.self, forKey: .udp) ?? false
    }
}

struct ProxyData: Codable {
    var items:[ProxyItemData] = []
    var datas:[String:ProxyItemData] = [:]
    var orderedSelections:[ProxyItemData] = []
    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
        
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        var array = [ProxyItemData]()
        for key in container.allKeys {
            let decodedObject = try container.decode(ProxyItemData.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            datas[key.stringValue] = decodedObject
            array.append(decodedObject)
        }
        items = array
        if let all = datas["GLOBAL"]?.all {
            for i in 0..<all.count {
                if let item = datas[all[i]] {
                    if item.type == "Selector" || item.type == "URLTest" {
                        orderedSelections.append(item)
                    }
                }
            }
        }
        for i in 0..<orderedSelections.count {
            print("ordered \(i) \(orderedSelections[i].name)")
        }
    }
    
    init(items: [ProxyItemData]) {
        self.items = items
    }
}

struct ProxiesData: Codable {
    var proxies:ProxyData = ProxyData(items: [])
}

class ProxyModel: ObservableObject {
    @Published var proxiesData:ProxiesData = {
        var data:ProxiesData? = nil
        do {
            data = try JSONDecoder().decode(ProxiesData.self, from: "{\"proxies\":{}}".data(using: .utf8)!)
        } catch let error {
            print("error \(error)")
        }
        return data!
    }()
    private var cancellables = Set<AnyCancellable>()
    
    public func update(_ server:Server) {
        let url = "http://\(server.host):\(server.port)/proxies"
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        NetworkManager.shared.getData(url: url, type: ProxiesData.self, headers: headers)
            .sink { completion in
                switch completion {
                case .failure(let err):
                    print("error fetch from \(url) : \(err.localizedDescription)")
                case .finished:
                    print("network fetch from \(url) finished")
                }
            }
            receiveValue: { [weak self] data in
                self?.proxiesData = data
            }
            .store(in: &cancellables)
    }
}

#if DEBUG
var previewProxyData:ProxiesData = getLocalData("proxies")
#endif
