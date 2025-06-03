import Foundation
import Combine
import SwiftUI

struct ProviderRuleItemData: Codable {
    var behavior: String
    var format: String
    var name: String
    var ruleCount: Int
    var type: String
    var vehicleType: String
    var updatedAt: String?
    var updatedAtDate: Date?
    var updatedAtStr: String?
}

struct ProviderRuleData: Codable {
    var items: [ProviderRuleItemData]
    
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
            var decodedObject = try container.decode(ProviderRuleItemData.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            if let updateAt = decodedObject.updatedAt {
                do {
                    let regex = try NSRegularExpression(pattern: "\\.[0-9]+Z")
                    let str = regex.stringByReplacingMatches(in: updateAt, range: NSMakeRange(0, updateAt.lengthOfBytes(using: .utf8)), withTemplate: "Z")
                    decodedObject.updatedAtDate = ISO8601DateFormatter().date(from: str)
                    decodedObject.updatedAtStr = DateFormatter.localizedString(from: decodedObject.updatedAtDate ?? Date(), dateStyle: .medium, timeStyle: .short)
                } catch {
                    print("update at regex error: \(error)")
                }
            }
            self.items.append(decodedObject)
        }
    }
}

struct RuleProviderData: Codable {
    var providers: ProviderRuleData
}

struct ProviderItemData: Codable {
    var name: String
    var proxies: [ProxyItemData]
    var type: String
    var vehicleType: String
    var updatedAt: String?
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

class ProviderModel: ObservableObject {
    private var currentServer: Server? = nil
    @Published var providerRuleData:RuleProviderData = {
        var data:RuleProviderData? = nil
        do {
            data = try JSONDecoder().decode(RuleProviderData.self, from: "{\"providers\":{}}".data(using: .utf8)!)
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

    func loadProviderRule(_ server:Server) {
        currentServer = server
        let url = "http://\(server.host):\(server.port)/providers/rules"
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        NetworkManager.shared.getData(url: url, type: RuleProviderData.self, headers: headers)
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
                    self?.providerRuleData = data
                }
            }
            .store(in: &cancellables)
    }

    func updateProviderRule(_ server:Server) {
        currentServer = server
        loadProviderRule(server)
    }
    
    public func updateProvider(_ server:Server, _ provider:String) {
        guard let encodedURL = provider.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return
        }
        let url = "\(server.https ? "https":"http")://\(server.host):\(server.port)/providers/rules/\(encodedURL)"
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        changeServerCancellable = NetworkManager.shared.putData(url: url, type: String.self, body: nil, headers: headers).sink { _ in
            self.loadProviderRule(server)
        } receiveValue: { str in
            if let str = str {
                print("receive \(str)")
            }
        }
    }
}
