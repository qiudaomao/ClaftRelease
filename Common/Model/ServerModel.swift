//
//  ServerModel.swift
//  claft
//
//  Created by zfu on 2022/2/26.
//

import Foundation
import Combine

enum ConnectStatus: Int, Codable {
    case none
    case connecting
    case connected
    case failed
}

enum WebSocketType {
    case traffic
    case connections
    case logs
    case ping
}

struct Server: Codable {
    var id: UUID = UUID()
    var host:String = ""
    var port:String = ""
    var secret:String? = nil
    var https:Bool = false
    var websockets:WebSockets? = nil

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case host = "host"
        case port = "port"
        case secret = "secret"
        case https = "https"
        case websockets = "websockets"
    }
    
    init() {}
    init(id: UUID, host: String, port: String, secret: String? = nil, https: Bool = false) {
        self.id = id
        self.host = host
        self.port = port
        self.secret = secret
        self.https = https
    }
//        let server = Server(id: 0, host: "127.0.0.1", port: "9090", secret: nil, https: false)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let idstr = try container.decodeIfPresent(String.self, forKey: .id)
        if let idstr = idstr, let id = UUID(uuidString: idstr) {
            self.id = id
        } else {
            id = UUID()
        }
        host = try container.decodeIfPresent(String.self, forKey: .host) ?? ""
        port = try container.decodeIfPresent(String.self, forKey: .port) ?? ""
        secret = try container.decodeIfPresent(String.self, forKey: .secret)
        https = try container.decodeIfPresent(Bool.self, forKey: .https) ?? false
        websockets = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(host, forKey: .host)
        try container.encode(port, forKey: .port)
        if let secret = secret {
            try container.encode(secret, forKey: .secret)
        }
        try container.encode(https, forKey: .https)
    }
}

class WebSockets: NSObject {
    var server: Server
    var trafficWebSocket:WebSocketModel
    var connectionWebSocket:WebSocketModel
    var logWebSocket:WebSocketModel
    var pingWebSocket:WebSocketModel
    init(_ server:Server) {
        self.server = server
        self.trafficWebSocket = WebSocketModel(.traffic, server)
        self.connectionWebSocket = WebSocketModel(.connections, server)
        self.logWebSocket = WebSocketModel(.logs, server)
        self.pingWebSocket = WebSocketModel(.ping, server)
    }
    
    func connectAll() {
        connect(.traffic)
        connect(.connections)
        connect(.log)
        connect(.ping)
    }
    
    func disconnectAll() {
        disconnect(.traffic)
        disconnect(.connections)
        disconnect(.log)
        disconnect(.ping)
    }
    
    func connect(_ type:SocketType) {
        switch type {
        case .traffic:
            self.trafficWebSocket.connect()
        case .connections:
            self.connectionWebSocket.connect()
        case .log:
            self.logWebSocket.connect()
        case .ping:
            self.pingWebSocket.connect()
        }
    }
    
    func disconnect(_ type:SocketType) {
        switch type {
        case .traffic:
            self.trafficWebSocket.disconnect()
        case .connections:
            self.connectionWebSocket.disconnect()
        case .log:
            self.logWebSocket.disconnect()
        case .ping:
            self.pingWebSocket.disconnect()
        }
    }
}

struct ChangeProxyBody: Codable {
    var name: String = ""
}

class ServerModel: ObservableObject {
    @Published var servers:[Server] = []
    @Published var currentServerIndex:Int = 0
    private var cancelables:Set<AnyCancellable> = Set<AnyCancellable>()

    public func connectServer(_ idx:Int) {
        if servers[idx].websockets == nil {
            servers[idx].websockets = WebSockets(servers[idx])
        }
        servers[idx].websockets?.connect(.traffic)
//        servers[idx].websockets?.connect(.ping)
    }

    func changeCurrentServer(_ idx:Int) {
        if idx >= 0 && idx < servers.count {
            self.currentServerIndex = idx
        }
        //save here
        let userDefault = UserDefaults.standard
        userDefault.set(self.currentServerIndex, forKey: "currentServerIndex")
    }
    
    public func loadServers() {
        let userDefault = UserDefaults.standard
        guard let serverstr = userDefault.object(forKey: "servers") as? String else {
            return
        }
        guard let serverdata = serverstr.data(using: .utf8) else {
            return
        }
        var servers:[Server]? = nil
        do {
            servers = try JSONDecoder().decode([Server].self, from: serverdata)
        } catch {
            print("error \(error)")
        }
        guard let servers = servers else {
            return
        }

        self.servers = servers
        /*
        self.servers = [
            Server(id: 0, host: "192.168.23.1", port: "9191", secret: "061x09bg33"),
            Server(id: 1, host: "127.0.0.1", port: "9090", https: false),
            Server(id: 2, host: "192.168.111.2", port: "9191", secret: "061x09bg33"),
            Server(id: 3, host: "serverD", port: "9092", secret: "def", https: true)
        ]
         */
        for i in 0..<self.servers.count {
            self.servers[i].websockets = WebSockets(servers[i])
            connectServer(i)
        }
//        if servers.count > 1 {
//            connectServer(0)
//            connectServer(1)
//            connectServer(2)
//        }
//        let userDefault = UserDefaults.standard
        if let idx = userDefault.object(forKey: "currentServerIndex") as? Int {
            if servers.count > idx {
                self.currentServerIndex = idx
                return
            }
        }
        if servers.count > 0 {
            self.currentServerIndex = 0
        }
    }
    
    public func disconnectAll() {
        for i in 0..<servers.count {
            servers[i].websockets?.disconnectAll()
        }
    }
    
    public func saveServers() {
        let userDefault = UserDefaults.standard
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(servers)
            guard let str = String(data: data, encoding: .utf8) else {
                return
            }
            print("str \(str)")
            userDefault.set(str, forKey: "servers")
        } catch {
            print("error \(error)")
        }
    }
    
    public func changeProxy(_ selector:String, _ target:String) -> Future<String?, Error>? {
//        NetworkManager.putData(url)
        let server = servers[currentServerIndex]
        guard let encodedURL = selector.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
            return nil
        }
        let url = "\(server.https ? "https":"http")://\(server.host):\(server.port)/proxies/\(encodedURL)"
        let body = ChangeProxyBody(name: target)
        var headers:[String:String] = [:]
        if let secret = server.secret {
            headers["Authorization"] = "Bearer \(secret)"
        }
        return NetworkManager.shared.putData(url: url, type: ChangeProxyBody.self, body: body, headers: headers)
    }
}
