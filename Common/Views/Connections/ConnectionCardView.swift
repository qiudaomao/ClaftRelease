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
        #if os(tvOS)
        let scale = 2.0
        #else
        let scale = 1.0
        #endif
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(connectionItem.metadata.network)")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .frame(minWidth: 40)
                        .font(.system(size: 10 * scale))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                    Text("\(connectionItem.metadata.type)")
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .frame(minWidth: 52)
                        .font(.system(size: 10 * scale))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                    if connectionItem.metadata.dnsMode.lengthOfBytes(using: .utf8) > 0 {
                    Text("\(connectionItem.metadata.dnsMode)")
                        .frame(minWidth: 36)
                        .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                        .font(.system(size: 10 * scale))
                        .background(Color("tagBackground"))
                        .cornerRadius(8)
                    }
                    Spacer()
                    Image(systemName: "arrowtriangle.up.fill")
                        .font(.system(size: 10 * scale))
                        .foregroundColor(Color.green)
                    Text("\(connectionItem.upload.humanReadableByteCount())")
                        .lineLimit(1)
                        .frame(minWidth: 46, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 10 * scale))
                        .foregroundColor(.gray)
                    Image(systemName: "arrowtriangle.down.fill")
                        .font(.system(size: 10 * scale))
                        .foregroundColor(Color.green)
                    Text("\(connectionItem.download.humanReadableByteCount())")
                        .lineLimit(1)
                        .frame(minWidth: 46, alignment: .trailing)
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 10 * scale))
                        .foregroundColor(.gray)
                }
                .frame(height: 20 * scale)
                .padding(EdgeInsets(top: 4, leading: 8, bottom: 0, trailing: 8))
                HStack() {
                    Image(systemName: "arrow.uturn.forward")
                        .foregroundColor(.gray)
                        .font(.system(size: 10 * scale))
                    VStack(alignment: .leading) {
                        HStack {
                            if connectionItem.metadata.host.lengthOfBytes(using: .utf8) > 0 {
                                Text("\(connectionItem.metadata.host)")
                                    .font(.system(size: 10 * scale))
                                    .lineLimit(1)
                                Text("\(connectionItem.metadata.destinationIP)")
                                    .font(.system(size: 10 * scale))
                                    .lineLimit(1)
                            } else {
                                Text("\(connectionItem.metadata.destinationIP)")
                                    .font(.system(size: 10 * scale))
                                    .lineLimit(1)
                            }
                            Spacer()
                            Text("\(connectionItem.metadata.destinationPort)")
                                .font(.system(size: 10 * scale))
                                .frame(width: 40 * scale)
                                .background(Color("tagBackground"))
                        }
                        .frame(height: 10 * scale)
                        HStack {
                            Text("\(connectionItem.metadata.sourceIP)")
                                .font(.system(size: 10 * scale))
                            Spacer()
                            Text("\(connectionItem.metadata.sourcePort)")
                                .font(.system(size: 10 * scale))
                                .frame(width: 40 * scale)
                                .background(Color("tagBackground"))
                        }
                        .frame(height: 10 * scale)
                    }
                }
                .frame(height: 20 * scale)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                HStack() {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.gray)
                        .font(.system(size: 10 * scale))
                    Text("\(connectionItem.rule)")
                        .font(.system(size: 10 * scale))
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                    Text("\(connectionItem.rulePayload)")
                        .font(.system(size: 10 * scale))
                }
                .frame(height: 18 * scale)
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                HStack() {
                    Image(systemName: "arrow.triangle.branch")
                        .foregroundColor(.gray)
                        .font(.system(size: 10 * scale))
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack {
                            ForEach(0..<connectionItem.chains.count, id: \.self) { i in
                                Text("\(connectionItem.chains[i])")
                                    .font(.system(size: 10 * scale))
                                Image(systemName: "arrow.left.to.line.compact")
                                    .font(.system(size: 10 * scale))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .frame(height: 14 * scale)
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 8))
            }
            #if os(tvOS)
            .frame(height: 200, alignment: .topLeading)
            #else
            .frame(height: 98, alignment: .topLeading)
            #endif
        }
//        .background(Color("connectionCard"))
//        .background(Material.thickMaterial)
        .modifier(CardBackgroundModifier())
        .cornerRadius(8 * scale)
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 2))
    }
}

#if DEBUG
struct ConnectionCardView_Previews: PreviewProvider {
    static var connectionData = previewConnectionData
    static var previews: some View {
        #if os(tvOS)
        Group {
            ConnectionCardView(connectionItem: connectionData.connections[0])
                .previewLayout(.fixed(width: 800, height: 200))
            ConnectionCardView(connectionItem: connectionData.connections[1])
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 800, height: 200))
        }
        #else
        Group {
            ConnectionCardView(connectionItem: connectionData.connections[0])
                .previewLayout(.fixed(width: 360, height: 100))
            ConnectionCardView(connectionItem: connectionData.connections[1])
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 360, height: 100))
        }
        #endif
    }
}
#endif
