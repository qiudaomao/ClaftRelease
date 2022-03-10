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
        #if os(tvOS)
        let scale = 2.0
        #else
        let scale = 1.0
        #endif
        return HStack {
            ZStack {
                VStack {
                    HStack {
                        if server.secret != nil {
                            if server.https {
                                Image(systemName: "network.badge.shield.half.filled")
                                    .font(Font.system(size: 10 * scale))
                                    .frame(width: 20)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "network.badge.shield.half.filled")
                                    .font(Font.system(size: 10 * scale))
                                    .frame(width: 20)
                                    .foregroundColor(.blue)
                            }
                        } else {
                            if server.https {
                                Image(systemName: "network")
                                    .font(Font.system(size: 10 * scale))
                                    .frame(width: 20)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "network")
                                    .font(Font.system(size: 10 * scale))
                                    .frame(width: 20)
                                    .foregroundColor(.blue)
                            }
                        }
                        Text("\(server.host)")
                            .font(Font.system(size: 10 * scale))
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "link.circle")
                            .font(Font.system(size: 10 * scale))
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        Text("\(server.port)")
                            .font(Font.system(size: 10 * scale))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    HStack {
                        if trafficData.up > 0 {
                            Image(systemName: "arrowtriangle.up.fill")
                                .font(Font.system(size: 10 * scale))
                                .foregroundColor(.blue)
                                .frame(width: 20)
                        } else {
                            Image(systemName: "arrowtriangle.up")
                                .font(Font.system(size: 10 * scale))
                                .foregroundColor(.blue)
                                .frame(width: 20)
                        }
                        Text("\(trafficData.up.humanReadableByteCount())/s")
                            .font(Font.system(size: 10 * scale))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    HStack {
                        if trafficData.down > 0 {
                            Image(systemName: "arrowtriangle.down.fill")
                                .font(Font.system(size: 10 * scale))
                                .foregroundColor(.blue)
                                .frame(width: 20)
                        } else {
                            Image(systemName: "arrowtriangle.down")
                                .font(Font.system(size: 10 * scale))
                                .foregroundColor(.blue)
                                .frame(width: 20)
                        }
                        Text("\(trafficData.down.humanReadableByteCount())/s")
                            .font(Font.system(size: 10 * scale))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                }
                #if os(tvOS)
                .frame(width: 300)
                .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 0))
                #else
                .padding(EdgeInsets(top: 5, leading: 6, bottom: 5, trailing: 0))
                .frame(width: 120)
                #endif
                switch trafficData.connectionStatus {
                case .none:
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
                    #if os(tvOS)
                        .position(x: 290, y: 8 * scale)
                    #else
                        .position(x: 110 * scale, y: 8 * scale)
                    #endif
                        .foregroundColor(.gray)
                case .connecting:
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
                        #if os(tvOS)
                            .position(x: 290, y: 8 * scale)
                        #else
                            .position(x: 110 * scale, y: 8 * scale)
                        #endif
                        .foregroundColor(.blue)
                case .connected:
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
#if os(tvOS)
    .position(x: 290, y: 8 * scale)
#else
    .position(x: 110 * scale, y: 8 * scale)
#endif
                        .foregroundColor(.green)
                case .failed:
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
#if os(tvOS)
    .position(x: 290, y: 8 * scale)
#else
    .position(x: 110 * scale, y: 8 * scale)
#endif
                        .foregroundColor(.red)
                }
                #if os(macOS)
                if selected {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 8 * scale))
                        .position(x: 111, y: 50)
                        .foregroundColor(.blue)
                }
                #elseif os(tvOS)
                if selected {
                    Image(systemName: "checkmark")
                        .font(Font.system(size: 8 * scale))
                        .position(x: 290, y: 105)
                        .foregroundColor(.blue)
                }
                #endif
            }
        }
        #if os(tvOS)
        .frame(width: 300, height: 120)
        #else
        .frame(width: 120, height: 60)
        #endif
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
        #if os(tvOS)
        Group {
            ServerCard(server: Server(id: UUID(), host: "192.168.23.1", port: "9090"), trafficData: TrafficData(up: 2314, down: 71645, connectionStatus: .none), selected: false)
                .previewLayout(.fixed(width: 300, height: 120))
            ServerCard(server: Server(id: UUID(), host: "127.0.0.1", port: "9090", secret: "abc"), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .connecting), selected: true)
                .previewLayout(.fixed(width: 300, height: 120))
            ServerCard(server: Server(id: UUID(), host: "127.0.0.1", port: "9090", https: true), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .connected), selected: false)
                .previewLayout(.fixed(width: 300, height: 120))
            ServerCard(server: Server(id: UUID(), host: "127.0.0.1", port: "9090", secret: "abc", https: true), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .failed), selected: true)
                .previewLayout(.fixed(width: 300, height: 120))
        }
        #else
        Group {
            ServerCard(server: Server(id: UUID(), host: "127.0.0.1", port: "9090"), trafficData: TrafficData(up: 2314, down: 71645, connectionStatus: .none), selected: false)
                .previewLayout(.fixed(width: 140, height: 80))
            ServerCard(server: Server(id: UUID(), host: "127.0.0.1", port: "9090", secret: "abc"), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .connecting), selected: true)
                .previewLayout(.fixed(width: 140, height: 80))
            ServerCard(server: Server(id: UUID(), host: "127.0.0.1", port: "9090", https: true), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .connected), selected: false)
                .previewLayout(.fixed(width: 140, height: 80))
            ServerCard(server: Server(id: UUID(), host: "127.0.0.1", port: "9090", secret: "abc", https: true), trafficData: TrafficData(up: 0, down: 0, connectionStatus: .failed), selected: true)
                .previewLayout(.fixed(width: 140, height: 80))
        }
        #endif
    }
}
