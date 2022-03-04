//
//  ServerCard.swift
//  claft
//
//  Created by zfu on 2021/11/30.
//

import SwiftUI
import Combine

struct ServerCard: View {
    @EnvironmentObject var serverModel:ServerModel
    var server: Server
    @State var trafficData: TrafficData
    @State var trafficDataCancellable:AnyCancellable? = nil
    @State var statusCancellable:AnyCancellable? = nil
    var selected:Bool
    var body: some View {
        HStack {
            ZStack {
                VStack {
                    HStack {
                        if server.secret != nil {
                            if server.https {
                                Image(systemName: "network.badge.shield.half.filled")
                                    .font(Font.system(size: 10))
                                    .frame(width: 20)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "network.badge.shield.half.filled")
                                    .font(Font.system(size: 10))
                                    .frame(width: 20)
                                    .foregroundColor(.blue)
                            }
                        } else {
                            if server.https {
                                Image(systemName: "network")
                                    .font(Font.system(size: 10))
                                    .frame(width: 20)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "network")
                                    .font(Font.system(size: 10))
                                    .frame(width: 20)
                                    .foregroundColor(.blue)
                            }
                        }
                        Text("\(server.host)")
                            .font(Font.system(size: 10))
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "link.circle")
                            .font(Font.system(size: 10))
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("\(server.port)")
                            .font(Font.system(size: 10))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    HStack {
                        if trafficData.up > 0 {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(Font.system(size: 10))
                                .foregroundColor(.blue)
                                .frame(width: 20)
                        } else {
                            Image(systemName: "arrowtriangle.up")
                                .font(Font.system(size: 10))
                                .foregroundColor(.blue)
                                .frame(width: 20)
                        }
                        Text("\(trafficData.up.humanReadableByteCount())/s")
                            .font(Font.system(size: 10))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    HStack {
                        if trafficData.down > 0 {
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(Font.system(size: 10))
                                .foregroundColor(.blue)
                                .frame(width: 20)
                        } else {
                            Image(systemName: "arrowtriangle.down")
                                .font(Font.system(size: 10))
                                .foregroundColor(.blue)
                                .frame(width: 20)
                        }
                        Text("\(trafficData.down.humanReadableByteCount())/s")
                            .font(Font.system(size: 10))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                }
                .padding(EdgeInsets(top: 5, leading: 6, bottom: 5, trailing: 0))
                .frame(width: 120)
                switch trafficData.connectionStatus {
                case .none:
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8))
                        .position(x: 110, y: 8)
                        .foregroundColor(.gray)
                case .connecting:
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8))
                        .position(x: 110, y: 8)
                        .foregroundColor(.blue)
                case .connected:
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8))
                        .position(x: 110, y: 8)
                        .foregroundColor(.green)
                case .failed:
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8))
                        .position(x: 110, y: 8)
                        .foregroundColor(.red)
                }
                #if os(macOS)
                if selected {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 8))
                        .position(x: 110, y: 50)
                        .foregroundColor(.blue)
                }
                #endif
            }
        }
        .frame(width: 120, height: 60)
        #if os(iOS)
        .overlay(SpecificCornerShape(
            topLeft: 8, bottomLeft: 8, topRight: 8, bottomRight: 8
        ).stroke(selected ? .blue : .gray, lineWidth: 1))
        #else
//        .border(.secondary, width: 1)
        .background(Color("connectionCard"))
        .cornerRadius(8)
        #endif
        .onAppear {
            trafficDataCancellable = server.websockets?.trafficWebSocket.$trafficData.sink(receiveValue: {data in
                trafficData = data
            })
        }
        .onDisappear {
            //disconnected
            trafficDataCancellable = nil
        }
    }
}

struct ServerCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090"), trafficData: TrafficData(up: 2314, down: 71645, connectionStatus: .none), selected: false)
                .previewLayout(.fixed(width: 140, height: 80))
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", secret: "abc"), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .connecting), selected: true)
                .previewLayout(.fixed(width: 140, height: 80))
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", https: true), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .connected), selected: false)
                .previewLayout(.fixed(width: 140, height: 80))
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", secret: "abc", https: true), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .failed), selected: true)
                .previewLayout(.fixed(width: 140, height: 80))
        }
    }
}
