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
}

struct Server {
    var id: Int
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
    init(_ server:Server) {
        self.server = server
        self.trafficWebSocket = WebSocketModel(.traffic, server)
        self.connectionWebSocket = WebSocketModel(.connections, server)
        self.logWebSocket = WebSocketModel(.logs, server)
    }
    
    func connectAll() {
        connect(.traffic)
        connect(.connections)
        connect(.log)
    }
    
    func disconnectAll() {
        disconnect(.traffic)
        disconnect(.connections)
        disconnect(.log)
    }
    
    func connect(_ type:SocketType) {
        switch type {
        case .traffic:
            self.trafficWebSocket.connect()
        case .connections:
            self.connectionWebSocket.connect()
        case .log:
            self.logWebSocket.connect()
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
        }
    }
}

class ServerModel: ObservableObject {
    @Published var servers:[Server] = []

    public func connectServer(_ idx:Int) {
        servers[idx].websockets?.connect(.traffic)
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
    
    public func saveServers() {
        let userDefault = UserDefaults.standard
        userDefault.set(servers, forKey: "servers")
    }
}
