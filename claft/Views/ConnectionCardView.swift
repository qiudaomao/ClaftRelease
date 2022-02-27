//
//  ConnectionCardView.swift
//  claft
//
//  Created by zfu on 2022/2/27.
//

import SwiftUI

struct ConnectionCardView: View {
    var connectionItem:ConnectionItem
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(connectionItem.metadata.network)")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .font(.system(size: 10))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                    Text("\(connectionItem.metadata.type)")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .font(.system(size: 10))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                    Text("\(connectionItem.metadata.dnsMode)")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .font(.system(size: 10))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                    Spacer()
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.green)
                    Text("\(connectionItem.upload.humanReadableByteCount())")
                        .lineLimit(1)
                    //                    .frame(width: 66)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color.green)
                    Text("\(connectionItem.download.humanReadableByteCount())")
                        .lineLimit(1)
                    //                    .frame(width: 66)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .frame(height: 20)
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 0, trailing: 8))
                HStack() {
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                    VStack(alignment: .leading) {
                        HStack {
                            if connectionItem.metadata.host.lengthOfBytes(using: .utf8) > 0 {
                                Text("\(connectionItem.metadata.host)")
                                    .font(.system(size: 10))
                                    .lineLimit(1)
                                Text("\(connectionItem.metadata.destinationIP)")
                                    .font(.system(size: 10))
                                    .lineLimit(1)
                            } else {
                                Text("\(connectionItem.metadata.destinationIP)")
                                    .font(.system(size: 10))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text("\(connectionItem.metadata.destinationPort)")
                                .font(.system(size: 10))
                                .frame(width: 40)
                                .background(Color("tagBackground"))
                        }
                        .frame(height: 10)
                        HStack {
                            Text("\(connectionItem.metadata.sourceIP)")
                                .font(.system(size: 10))
                            Spacer()
                            Text("\(connectionItem.metadata.sourcePort)")
                                .font(.system(size: 10))
                                .frame(width: 40)
                                .background(Color("tagBackground"))
                        }
                        .frame(height: 10)
                    }
                }
                .frame(height: 20)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                HStack() {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                    Text("\(connectionItem.rule)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                    Text("\(connectionItem.rulePayload)")
                        .font(.system(size: 10))
                }
                .frame(height: 18)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                HStack() {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundColor(.gray)
                        .font(.system(size: 10))
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(0..<connectionItem.chains.count, id: \.self) { i in
                                Text("\(connectionItem.chains[i])")
                                    .font(.system(size: 10))
                                Image(systemName: "arrow.left.to.line.compact")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .frame(height: 14)
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 8))
            }
            .frame(height: 98, alignment: .topLeading)
        }
        .background(Color("connectionCard"))
        .cornerRadius(8)
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}

struct ConnectionCardView_Previews: PreviewProvider {
    static var connectionData = previewConnectionData
    static var previews: some View {
        Group {
            ConnectionCardView(connectionItem: connectionData.connections[0])
                .previewLayout(.fixed(width: 360, height: 100))
            ConnectionCardView(connectionItem: connectionData.connections[1])
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 360, height: 100))
        }
    }
}
