//
//  WebSocketModel.swift
//  claft
//
//  Created by zfu on 2022/2/26.
//

import Foundation
import Combine
import SwiftUI

enum SocketType {
    case traffic
    case connections
    case log
    case ping
}

struct TrafficData: Hashable, Codable {
    var up: Int = 0
    var down: Int = 0
    var connectionStatus: ConnectStatus = .none
    enum CodingKeys: String, CodingKey {
        case up = "up"
        case down = "down"
    }
}

struct ConnectionMetaData: Hashable, Codable {
    var network: String = ""
    var type: String = ""
    var sourceIP: String = ""
    var destinationIP: String = ""
    var sourcePort: String = ""
    var destinationPort: String = ""
    var host: String = ""
    var dnsMode: String = ""
    
    init() {}
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        network = try container.decodeIfPresent(String.self, forKey: .network) ?? ""
        type = try container.decodeIfPresent(String.self, forKey: .type) ?? ""
        sourceIP = try container.decodeIfPresent(String.self, forKey: .sourceIP) ?? ""
        destinationIP = try container.decodeIfPresent(String.self, forKey: .destinationIP) ?? ""
        sourcePort = try container.decodeIfPresent(String.self, forKey: .sourcePort) ?? ""
        destinationPort = try container.decodeIfPresent(String.self, forKey: .destinationPort) ?? ""
        host = try container.decodeIfPresent(String.self, forKey: .host) ?? ""
        dnsMode = try container.decodeIfPresent(String.self, forKey: .dnsMode) ?? ""
    }
}

struct ConnectionItem: Hashable, Codable {
    var id: String = ""
    var metadata: ConnectionMetaData = ConnectionMetaData()
    var upload: Int = 0
    var download: Int = 0
    var uploadSpeed: Int? = nil
    var downloadSpeed: Int? = nil
    var start: String = ""
    var chains: [String] = []
    var rule: String = ""
    var rulePayload: String = ""
    var closed: Bool? = nil
    var closeTime: String? = nil
    
    enum CodingKeys: String, CodingKey {
        case id, metadata, upload, download, start, chains, rule, rulePayload
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        metadata = try container.decodeIfPresent(ConnectionMetaData.self, forKey: .metadata) ?? ConnectionMetaData()
        upload = try container.decodeIfPresent(Int.self, forKey: .upload) ?? 0
        download = try container.decodeIfPresent(Int.self, forKey: .download) ?? 0
        start = try container.decodeIfPresent(String.self, forKey: .start) ?? ""
        chains = try container.decodeIfPresent([String].self, forKey: .chains) ?? []
        rule = try container.decodeIfPresent(String.self, forKey: .rule) ?? ""
        rulePayload = try container.decodeIfPresent(String.self, forKey: .rulePayload) ?? ""
        // These are not part of the JSON from server, only added locally
        closed = nil
        closeTime = nil
        uploadSpeed = nil
        downloadSpeed = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(upload, forKey: .upload)
        try container.encode(download, forKey: .download)
        try container.encode(start, forKey: .start)
        try container.encode(chains, forKey: .chains)
        try container.encode(rule, forKey: .rule)
        try container.encode(rulePayload, forKey: .rulePayload)
        // Don't encode closed, closeTime, uploadSpeed, downloadSpeed as they're not part of server JSON
    }
}

struct ConnectionData: Hashable, Codable {
    var downloadTotal: Int = 0
    var uploadTotal: Int = 0
    var connections: [ConnectionItem] = []
    var closedConnections: [ConnectionItem] = []
    
    enum CodingKeys: String, CodingKey {
        case downloadTotal, uploadTotal, connections
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        downloadTotal = try container.decodeIfPresent(Int.self, forKey: .downloadTotal) ?? 0
        uploadTotal = try container.decodeIfPresent(Int.self, forKey: .uploadTotal) ?? 0
        connections = try container.decodeIfPresent([ConnectionItem].self, forKey: .connections) ?? []
        // closedConnections is not part of server JSON, only managed locally
        closedConnections = []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(downloadTotal, forKey: .downloadTotal)
        try container.encode(uploadTotal, forKey: .uploadTotal)
        try container.encode(connections, forKey: .connections)
        // Don't encode closedConnections as it's not part of server JSON
    }
}

struct LogData: Hashable, Codable {
    var type: String = ""
    var payload: String = ""
}

class WebSocketModel: ObservableObject, WebSocketDelegate {
    private var websocket: WebSocket? = nil
    private var pingTimerCancellable:AnyCancellable? = nil
    @Published var trafficData:TrafficData = TrafficData()
    @Published var trafficHistory:[TrafficData] = []
    @Published var connectionData:ConnectionData = ConnectionData()
    @Published var logs:[LogData] = [LogData]()
    @Published var pingOK: Bool = false
    var type: WebSocketType = .traffic
    var server: Server
    private var failedTimes = 0
    private var clean: Bool = false
    init(_ type: WebSocketType, _ server: Server) {
        self.type = type
        self.server = server
    }
    
    private func connectTo(_ path:String?) -> WebSocket {
        if path == "ping" {
            let websocket = WebSocket()
            websocket.host = server.host
            websocket.port = server.port
            websocket.secret = server.secret
            websocket.https = server.https
            websocket.delegate = self
            websocket.open()
            return websocket
        }
        let websocket = WebSocket()
        websocket.host = server.host
        websocket.port = server.port
        websocket.secret = server.secret
        websocket.https = server.https
        websocket.path = path
        websocket.delegate = self
        websocket.open()
        return websocket
    }
    
    func connect() {
        print("connect \(type)")
        switch type {
        case .traffic:
            trafficData.connectionStatus = .connecting
            websocket = connectTo("traffic")
        case .connections:
            websocket = connectTo("connections")
        case .logs:
            websocket = connectTo("logs")
        case .ping:
            websocket = connectTo("ping")
        }
    }
    
    func disconnect() {
        print("disconnect \(type)")
        clean = true
        websocket?.close()
    }
    
    func onMessage(_ delegate:WebSocket, _ str: String) {
//        print("onMessage \(str)")
        if let data = str.data(using: .utf8) {
            do {
                switch type {
                case .traffic:
                    let trafficData = try JSONDecoder().decode(TrafficData.self, from: data)
//                    print("server up \(trafficData.up) down \(trafficData.down)")
                    self.trafficData.up = trafficData.up
                    self.trafficData.down = trafficData.down
                    
                    if self.trafficHistory.count > 99 {
                        self.trafficHistory.removeFirst()
                    }
                    self.trafficHistory.append(trafficData)
                case .connections:
                    var connectionData = try JSONDecoder().decode(ConnectionData.self, from: data)
                    //caculate speed
                    var idx = 0
                    for conn in connectionData.connections {
                        if let item = self.connectionData.connections.first(where: { obj in
                            obj.id == conn.id
                        }) {
                            connectionData.connections[idx].uploadSpeed = conn.upload - item.upload
                            connectionData.connections[idx].downloadSpeed = conn.download - item.download
                        }
                        idx += 1
                    }
                    
                    // Track closed connections
                    let currentConnectionIds = Set(connectionData.connections.map { $0.id })
                    let previousConnectionIds = Set(self.connectionData.connections.map { $0.id })
                    let closedConnectionIds = previousConnectionIds.subtracting(currentConnectionIds)
                    
                    // Mark closed connections and add to closedConnections
                    var newClosedConnections = self.connectionData.closedConnections
                    for closedId in closedConnectionIds {
                        if let closedConnection = self.connectionData.connections.first(where: { $0.id == closedId }) {
                            var closed = closedConnection
                            closed.closed = true
                            closed.closeTime = self.getCurrentTimeString()
                            newClosedConnections.append(closed)
                        }
                    }
                    
                    // Keep only last 100 closed connections
                    if newClosedConnections.count > 100 {
                        newClosedConnections = Array(newClosedConnections.suffix(100))
                    }
                    
                    connectionData.closedConnections = newClosedConnections
                    self.connectionData = connectionData
                case .logs:
                    let logData = try JSONDecoder().decode(LogData.self, from: data)
                    self.logs.append(logData)
                case .ping:
                    self.pingOK = true
//                    self.pingOK = true
                }
            } catch let error {
                print("error decode \(error)")
            }
        }
    }
    
    func onPong(_ delegate: WebSocket) {
        print("onPong \(type)")
        if type == .ping {
            self.pingOK = true
        }
    }
    
    func onError(_ delegate:WebSocket, _ str: String) {
        print("onError \(type) \(str)")
        if type == .traffic {
            trafficData.connectionStatus = .failed
        }
    }
    
    func date() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSSS"
        return formatter.string(from: date)
    }
    
    func getCurrentTimeString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    func onOpen(_ delegate:WebSocket) {
        clean = false
        print("onOpen \(type) \(server.host):\(server.port) at \(date())")
        failedTimes = 0
        if type == .traffic {
            trafficData.connectionStatus = .connected
        } else if type == .ping {
            pingTimerCancellable = Timer.publish(every: 5, tolerance: nil, on: .main, in: .default)
                .autoconnect()
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] _ in
                    guard let failedTimes = self?.failedTimes else {
                        return
                    }
                    print("timerout ping")
                    if failedTimes < 5 {
                        self?.websocket?.ping()
                    }
                })
        }
    }
    
    func onClose(_ delegate:WebSocket, _ clean:Bool) {
        print("onClose \(type) \(server.host):\(server.port) clean \(clean) self.clean \(self.clean) at \(date())")
        if type == .traffic {
            trafficData.connectionStatus = .none
        }
        if !self.clean {
            self.retry()
        }
    }
    
    func onFail(_ delegate:WebSocket, _ str: String) {
        print("onFail \(type) \(str)")
        if type == .traffic {
            trafficData.connectionStatus = .failed
        }
        self.retry()
    }
    
    func retry() {
        if failedTimes < 5 {
            failedTimes += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
                print("sleep 5 retry \(self?.failedTimes ?? -1)")
                self?.connect()
            }
        } else if failedTimes < 10 {
            failedTimes += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [weak self] in
                print("sleep 5 retry \(self?.failedTimes ?? -1)")
                self?.connect()
            }
        } else {
            failedTimes += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(30)) { [weak self] in
                print("sleep 30 retry \(self?.failedTimes ?? -1)")
                self?.connect()
            }
        }
    }
}
