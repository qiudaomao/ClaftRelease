//
//  ServerCard.swift
//  claft
//
//  Created by zfu on 2021/11/30.
//

import SwiftUI

struct ServerCard: View {
    var server:Server
    var selected:Bool
    var body: some View {
        ZStack {
            HStack {
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
                        Image(systemName: "bolt.horizontal.fill")
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
                }
                .padding(EdgeInsets(top: 5, leading: 6, bottom: 5, trailing: 0))
                .frame(width: 100)
            }
            .frame(width: 100, height: 40)
    //        .border(.secondary, width: 1)
            .overlay(SpecificCornerShape(
                topLeft: 8, bottomLeft: 8, topRight: 8, bottomRight: 8
            ).stroke(selected ? .blue : .gray, lineWidth: 1))
            Image(systemName: "circle.fill")
                .font(Font.system(size: 10))
                .position(x: 100, y: 20)
                .foregroundColor(.red)
        }
    }
}

struct ServerCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", up: 0, down: 0), selected: false)
                .previewLayout(.fixed(width: 120, height: 60))
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", up: 0, down: 0, secret: "abc"), selected: true)
                .previewLayout(.fixed(width: 120, height: 60))
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", up: 0, down: 0, https: true), selected: false)
                .previewLayout(.fixed(width: 120, height: 60))
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", up: 0, down: 0, secret: "abc", https: true), selected: true)
                .previewLayout(.fixed(width: 120, height: 60))
        }
    }
}
