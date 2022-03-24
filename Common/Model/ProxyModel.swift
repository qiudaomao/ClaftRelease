//
//  ProxyModel.swift
//  claft
//
//  Created by zfu on 2022/2/27.
//

import Foundation
import Combine
import SwiftUI

struct RenderData {
    var name: String = ""
    var now: String = ""
    var items: [ProxyItemData] = []
    var expanded: Bool = false
}

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
    var fromProvider: Bool = false

    init() {}
    
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

struct ProviderItemData: Codable {
    var name: String
    var proxies: [ProxyItemData]
}

struct ProviderData : Codable {
    var items: [ProviderItemData]
    
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
        items = []
        for key in container.allKeys {
            let decodedObject = try container.decode(ProviderItemData.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            self.items.append(decodedObject)
        }
    }
}

struct ProxyProviderData : Codable {
    var providers: ProviderData
}

class ProxyModel: ObservableObject {
    var currentServer: Server? = nil
    @Published var renderDatas:[RenderData] = []
    @Published var proxiesData:ProxiesData = {
        var data:ProxiesData? = nil
        do {
            data = try JSONDecoder().decode(ProxiesData.self, from: "{\"proxies\":{}}".data(using: .utf8)!)
        } catch let error {
            print("error \(error)")
        }
        return data!
    }()
    @Published var proxyProviderData:ProxyProviderData = {
        var data:ProxyProviderData? = nil
        do {
            data = try JSONDecoder().decode(ProxyProviderData.self, from: "{\"providers\":{}}".data(using: .utf8)!)
        } catch let error {
            print("error \(error)")
        }
        return data!
    }()
    private var cancellables = Set<AnyCancellable>()
    private var changeServerCancellable: AnyCancellable? = nil

    init() {
        var proxiesPublisher: AnyPublisher<[RenderData], Never> {
            return Publishers.CombineLatest($proxiesData, $proxyProviderData).map { data, providerData -> [RenderData] in
                self.proxiesData = data
                let renderDatas = data.proxies.orderedSelections
                    .map({ item -> RenderData in
                    var renderItem = RenderData()
                    renderItem.name = item.name
                    renderItem.now = item.now
                    renderItem.items = item.all
                            .filter({ name in
                                if data.proxies.datas.keys.contains(name) {
                                    return true
                                }
                                for provider in providerData.providers.items {
                                    for proxy in provider.proxies {
                                        if proxy.name == name {
                                            return true
                                        }
                                    }
                                }
                                return false
                            })
                            .map({ name in
                                for provider in providerData.providers.items {
                                    for proxy in provider.proxies {
                                        if proxy.name == name {
                                            var p = proxy
                                            p.fromProvider = true
                                            return p
                                        }
                                    }
                                }
                                return data.proxies.datas[name]!
                    })
                    return renderItem
                })
                #if os(tvOS)
                if proxiesData.proxies.orderedSelections.count > 0 {
                    if let proxy = proxiesData.proxies.orderedSelections.first {
                        focused = .item(section: 0, proxy: proxy.name)
                    }
                }
                #endif
                return renderDatas
            }.eraseToAnyPublisher()
        }
        proxiesPublisher.sink { renderDatas in
            self.renderDatas = renderDatas
        }.store(in: &cancellables)
    }
    
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
        updateProvider(server)
    }
    
    public func updateProvider(_ server:Server) {
        currentServer = server
        let url = "http://\(server.host):\(server.port)/providers/proxies"
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        NetworkManager.shared.getData(url: url, type: ProxyProviderData.self, headers: headers)
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
                    self?.proxyProviderData = data
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
            for idx in 0..<self.proxyProviderData.providers.items.count {
                for i in 0..<self.proxyProviderData.providers.items[idx].proxies.count {
                    if proxyProviderData.providers.items[idx].proxies[i].name == proxy {
                        proxyProviderData.providers.items[idx].proxies[i].history = []
                    }
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
                    if let items = self?.proxyProviderData.providers.items {
                        for idx in 0..<items.count {
                            if let proxies = self?.proxyProviderData.providers.items[idx].proxies {
                                for i in 0..<proxies.count {
                                    if self?.proxyProviderData.providers.items[idx].proxies[i].name == proxy {
                                        self?.proxyProviderData.providers.items[idx].proxies[i].history = [ProxyHistoryData(time: "", delay: data.delay)]
                                    }
                                }
                            }
                        }
                    }
                }
                .store(in: &cancellables)
        }
    }
    
    public func changeProxy(_ server:Server, _ selector:String, _ target:String) {
        if currentServer?.id != server.id {
            return
        }
//        NetworkManager.putData(url)
//        let server = servers[currentServerIndex]
        guard let encodedURL = selector.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        let url = "\(server.https ? "https":"http")://\(server.host):\(server.port)/proxies/\(encodedURL)"
        let body = ChangeProxyBody(name: target)
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        changeServerCancellable = NetworkManager.shared.putData(url: url, type: ChangeProxyBody.self, body: body, headers: headers).sink { _ in
            self.update(server)
        } receiveValue: { str in
            if let str = str {
                print("receive \(str)")
            }
        }

    }
}

#if DEBUG
var previewProxyData:ProxiesData = getLocalData("proxies")
#endif
