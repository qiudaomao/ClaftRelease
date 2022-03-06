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

struct Server {
    var id: Int = 0
    var host:String = ""
    var port:String = ""
    var secret:String? = nil
    var https:Bool = false
    var websockets:WebSockets? = nil
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
        servers[idx].websockets?.connect(.traffic)
//        servers[idx].websockets?.connect(.ping)
    }

    func changeCurrentServer(_ idx:Int) {
        if idx >= 0 && idx < servers.count {
            self.currentServerIndex = idx
        }
    }
    
    public func loadServers() {
        /*
        let userDefault = UserDefaults.standard
        guard let servers = userDefault.object(forKey: "servers") as? [Server] else {
            return
        }
        self.servers = servers
         */
        self.servers = [
            Server(id: 0, host: "192.168.23.1", port: "9191", secret: "061x09bg33"),
            Server(id: 1, host: "127.0.0.1", port: "9090", https: false),
            Server(id: 2, host: "192.168.111.2", port: "9191", secret: "061x09bg33"),
            Server(id: 3, host: "serverD", port: "9092", secret: "def", https: true)
        ]
        for i in 0..<servers.count {
            servers[i].websockets = WebSockets(servers[i])
            connectServer(i)
        }
        if servers.count > 1 {
            connectServer(0)
            connectServer(1)
            connectServer(2)
        }
    }
    
    public func disconnectAll() {
        for i in 0..<servers.count {
            servers[i].websockets?.disconnectAll()
        }
    }
    
    public func saveServers() {
        let userDefault = UserDefaults.standard
        userDefault.set(servers, forKey: "servers")
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
