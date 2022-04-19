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
}

struct ConnectionData: Hashable, Codable {
    var downloadTotal: Int = 0
    var uploadTotal: Int = 0
    var connections: [ConnectionItem] = []
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
