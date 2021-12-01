//
//  ServerCard.swift
//  claft
//
//  Created by zfu on 2021/11/30.
//

import SwiftUI

struct ServerCard: View {
    var server:Server
    var body: some View {
        HStack {
            VStack {
                HStack {
                    if server.secret != nil {
                        Image(systemName: "network.badge.shield.half.filled")
                            .font(Font.system(size: 10))
                            .frame(width: 20)
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "network")
                            .font(Font.system(size: 10))
                            .frame(width: 20)
                            .foregroundColor(.blue)
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
        .border(.secondary, width: 1)
        .cornerRadius(20, antialiased: false)
    }
}

struct ServerCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", up: 0, down: 0))
                .previewLayout(.fixed(width: 100, height: 40))
            ServerCard(server: Server(id: 0, host: "127.0.0.1", port: "9090", up: 0, down: 0, secret: "abc"))
                .previewLayout(.fixed(width: 120, height: 60))
        }
    }
}
