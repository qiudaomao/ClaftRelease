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
}

struct ConnectionItem: Hashable, Codable {
    var id: String = ""
    var metadata: ConnectionMetaData = ConnectionMetaData()
    var upload: Int = 0
    var download: Int = 0
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
    @Published var connectionData:ConnectionData = ConnectionData()
    @Published var logs:[LogData] = [LogData]()
    @Published var pingOK: Bool = false
    var type: WebSocketType = .traffic
    var server: Server
    private var failedTimes = 0
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
        switch type {
        case .traffic:
            trafficData.connectionStatus = .connecting
            websocket = connectTo("traffic")
        case .connections:
            websocket = connectTo("connections")
        case .logs:
            websocket = connectTo("log")
        case .ping:
            websocket = connectTo("ping")
        }
    }
    
    func disconnect() {
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
                case .connections:
                    let connectionData = try JSONDecoder().decode(ConnectionData.self, from: data)
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
        print("onPong")
        if type == .ping {
            self.pingOK = true
        }
    }
    
    func onError(_ delegate:WebSocket, _ str: String) {
        print("onError \(str)")
        if type == .traffic {
            trafficData.connectionStatus = .failed
        }
    }
    
    func onOpen(_ delegate:WebSocket) {
        print("onOpen \(type)")
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
    
    func onClose(_ delegate:WebSocket) {
        print("onClose")
        if type == .traffic {
            trafficData.connectionStatus = .none
        }
    }
    
    func onFail(_ delegate:WebSocket, _ str: String) {
        print("onFail \(str)")
        if type == .traffic {
            trafficData.connectionStatus = .failed
        }
    }
}
