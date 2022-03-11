//
//  ProxyModel.swift
//  claft
//
//  Created by zfu on 2022/2/27.
//

import Foundation
import Combine
import SwiftUI

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

struct DelayData: Codable {
    var delay: Int = 0
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
                withAnimation {
                    self?.proxiesData = data
                }
            }
            .store(in: &cancellables)
    }
    
    public func updateDelay(_ server:Server, proxies:[String]) {
        for proxy in proxies {
            guard let encodedName = proxy.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                continue
            }
            let checkURL = "http://www.gstatic.com/generate_204"
            let url = "\(server.https ? "https":"http")://\(server.host):\(server.port)/proxies/\(encodedName)/delay?timeout=5000&url=\(checkURL)"
            var headers:[String:String] = [:]
            if let secret = server.secret {
                headers["Authorization"] = "Bearer \(secret)"
            }
            let items = self.proxiesData.proxies.items
            for idx in 0..<items.count {
                if items[idx].name == proxy {
                    print("latest clear \(proxy)")
                    self.proxiesData.proxies.items[idx].history = []
                }
            }
            for idx in 0..<self.proxiesData.proxies.orderedSelections.count {
                if self.proxiesData.proxies.orderedSelections[idx].name == proxy {
                    print("latest clear \(proxy)")
                    self.proxiesData.proxies.orderedSelections[idx].history = []
                }
            }
            self.proxiesData.proxies.datas[proxy]?.history = []
            NetworkManager.shared.getData(url: url, type: DelayData.self, headers: headers)
                .sink { completion in
                    switch completion {
                    case .failure(let err):
                        print("error fetch from \(url) : \(err.localizedDescription)")
                    case .finished:
                        print("network fetch from \(url) finished")
                    }
                }
                receiveValue: { [weak self] data in
                    self?.proxiesData.proxies.datas[proxy]?.history = [ProxyHistoryData(time: "", delay: data.delay)]
                    if let items = self?.proxiesData.proxies.items {
                        for idx in 0..<items.count {
                            if items[idx].name == proxy {
                                print("latest \(proxy) -> \(data.delay)")
                                self?.proxiesData.proxies.items[idx].history = [ProxyHistoryData(time: "", delay: data.delay)]
                            }
                        }
                    }
                    if let items = self?.proxiesData.proxies.orderedSelections {
                        for idx in 0..<items.count {
                            if items[idx].name == proxy {
                                print("latest \(proxy) -> \(data.delay)")
                                self?.proxiesData.proxies.orderedSelections[idx].history = [ProxyHistoryData(time: "", delay: data.delay)]
                            }
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }
}

#if DEBUG
var previewProxyData:ProxiesData = getLocalData("proxies")
#endif
