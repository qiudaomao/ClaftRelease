//
//  WebSocket.swift
//  claft
//
//  Created by zfu on 2022/2/26.
//

import Foundation
import SocketRocket

protocol WebSocketDelegate:AnyObject {
    func onMessage(_ delegate:WebSocket, _ str:String)
    func onError(_ delegate:WebSocket, _ str:String)
    func onOpen(_ delegate:WebSocket)
    func onClose(_ delegate:WebSocket)
    func onFail(_ delegate:WebSocket, _ str:String)
    func onPong(_ delegate:WebSocket)
}

class WebSocket: NSObject, SRWebSocketDelegate {
    private var socketio: SRWebSocket?
    var host: String? = nil
    var port: String? = nil
    var path: String? = nil
    var secret: String? = nil
    var https: Bool = false
    var url: String? = nil
    weak var delegate:WebSocketDelegate?
    
    func open() {
        guard let host = host,
            let port = port else {
            return
        }
        var proto = "ws"
        if https {
            proto = "wss"
        }
        url = "\(proto)://\(host):\(port)"
        if let path = path {
            if let secret = secret {
                url = "\(proto)://\(host):\(port)/\(path)?token=\(secret)"
            } else {
                url = "\(proto)://\(host):\(port)/\(path)"
            }
        } else {
            if let secret = secret {
                url = "\(proto)://\(host):\(port)?token=\(secret)"
            } else {
                url = "\(proto)://\(host):\(port)"
            }
        }
        if let url = url {
            print("final url is \(url) path \(path ?? "no path")")
        }
        self.startWebSocket()
    }
    
    func ping() {
        do {
            try socketio?.sendPing(nil)
        } catch let error {
            print("ping exception \(error)")
        }
    }
    
    func close() {
        socketio?.close()
    }
    
    private func startWebSocket() {
        guard let urlstr = url else {
            return
        }
        guard let url = URL(string: urlstr) else {
            return
        }
        socketio = SRWebSocket(url: url)
        socketio?.delegate = self
        socketio?.open()
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceiveMessage message: Any) {
        guard let msg = message as? String else {
            return
        }
//        print("websocket Message: \(msg)\n")
        guard let delegate = delegate else {
            return
        }
        delegate.onMessage(self, msg)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didFailWithError error: Error) {
//        print("websocket didFailWithError \(error)")
        guard let delegate = delegate else {
            return
        }
        delegate.onFail(self, error.localizedDescription)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didReceivePong pongData: Data?) {
        delegate?.onPong(self)
    }
    
    func webSocket(_ webSocket: SRWebSocket, didCloseWithCode code: Int, reason: String?, wasClean: Bool) {
        if let reason = reason {
            print("websocket did close \(code) \(reason) \(wasClean)")
        }
        guard let delegate = delegate else {
            return
        }
        delegate.onClose(self)
    }
    
    func webSocketDidOpen(_ webSocket: SRWebSocket) {
//        print("websocket did open\n");
        guard let delegate = delegate else {
            return
        }
        delegate.onOpen(self)
    }
}
