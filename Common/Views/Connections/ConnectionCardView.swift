//
//  ConnectionCardView.swift
//  claft
//
//  Created by zfu on 2022/2/27.
//

import SwiftUI

struct ConnectionCardView: View {
    let callback: () -> Void
    var connectionItem:ConnectionItem
    
    private func getRelativeCloseTime(_ closeTimeString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let closeDate = formatter.date(from: closeTimeString) {
            let relativeTime = closeDate.updateStr
            if relativeTime.isEmpty {
                return "\("closed".localized) \("just now".localized)"
            } else {
                return "\("closed".localized) \(relativeTime)"
            }
        }
        return "\("closed".localized) \("recently".localized)"
    }
    
    var body: some View {
        #if os(tvOS)
        let scale = 2.0
        #else
        let scale = 1.0
        #endif
        let isClosedConnection = connectionItem.closed == true
        HStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        if isClosedConnection {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12 * scale))
                                .foregroundColor(.red)
                        }
                        Text("\(connectionItem.metadata.network)")
                            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                            .frame(minWidth: 40)
                            .font(.system(size: 10 * scale))
                            .background(isClosedConnection ? Color.red.opacity(0.3) : Color("tagBackground"))
                            .cornerRadius(8)
                        Text("\(connectionItem.metadata.type)")
                            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                            .frame(minWidth: 52)
                            .font(.system(size: 10 * scale))
                            .background(isClosedConnection ? Color.red.opacity(0.3) : Color("tagBackground"))
                            .cornerRadius(8)
                        if connectionItem.metadata.dnsMode.lengthOfBytes(using: .utf8) > 0 {
                        Text("\(connectionItem.metadata.dnsMode)")
                            .frame(minWidth: 36)
                            .padding(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
                            .font(.system(size: 10 * scale))
                            .background(isClosedConnection ? Color.red.opacity(0.3) : Color("tagBackground"))
                            .cornerRadius(8)
                        }
                        Spacer()
                        Image(systemName: "arrowtriangle.up.fill")
                            .font(.system(size: 10 * scale))
                            .foregroundColor(isClosedConnection ? Color.red.opacity(0.6) : Color.green)
                        Text("\(connectionItem.upload.humanReadableByteCount())")
                            .lineLimit(1)
                            .frame(minWidth: 46, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 10 * scale))
                            .foregroundColor(isClosedConnection ? .red.opacity(0.8) : .gray)
                        Image(systemName: "arrowtriangle.down.fill")
                            .font(.system(size: 10 * scale))
                            .foregroundColor(isClosedConnection ? Color.red.opacity(0.6) : Color.green)
                        Text("\(connectionItem.download.humanReadableByteCount())")
                            .lineLimit(1)
                            .frame(minWidth: 46, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 10 * scale))
                            .foregroundColor(isClosedConnection ? .red.opacity(0.8) : .gray)
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
                        Spacer()
                        Image(systemName: "arrowtriangle.up")
                            .font(.system(size: 10 * scale))
                            .foregroundColor(isClosedConnection ? Color.red.opacity(0.6) : Color.green)
                        Text(isClosedConnection ? "0 B/s" : "\((connectionItem.uploadSpeed ?? 0).humanReadableByteCount())/s")
                            .lineLimit(1)
                            .frame(minWidth: 46, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 10 * scale))
                            .foregroundColor(isClosedConnection ? .red.opacity(0.8) : .gray)
                        Image(systemName: "arrowtriangle.down")
                            .font(.system(size: 10 * scale))
                            .foregroundColor(isClosedConnection ? Color.red.opacity(0.6) : Color.green)
                        Text(isClosedConnection ? "0 B/s" : "\((connectionItem.downloadSpeed ?? 0).humanReadableByteCount())/s")
                            .lineLimit(1)
                            .frame(minWidth: 46, alignment: .trailing)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 10 * scale))
                            .foregroundColor(isClosedConnection ? .red.opacity(0.8) : .gray)
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
                            .contentShape(Rectangle())
                        }
                        .frame(height: 14 * scale)
                        HStack {
                            if isClosedConnection {
                                // Show close time for closed connections
                                if let closeTime = connectionItem.closeTime, !closeTime.isEmpty {
                                    Text(getRelativeCloseTime(closeTime))
                                        .font(.system(size: 10 * scale))
                                        .foregroundColor(.red.opacity(0.8))
                                }
                            } else {
                                // add a close image for active connections
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 10 * scale))
                                    .foregroundColor(.gray)
                                    .onTapGesture {
                                        // self.showConnectionDetails = false
                                        callback()
                                    }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 4, trailing: 8))
                }
                #if os(tvOS)
                .frame(height: 200, alignment: .topLeading)
                #else
                .frame(height: 106, alignment: .topLeading)
#endif
            }
        }
//        .background(Color("connectionCard"))
//        .background(Material.thickMaterial)
        .modifier(CardBackgroundModifier())
        .opacity(isClosedConnection ? 0.7 : 1.0)
        .overlay(
            RoundedRectangle(cornerRadius: 8 * scale)
                .stroke(isClosedConnection ? Color.red.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .cornerRadius(8 * scale)
        .padding(EdgeInsets(top: 0, leading: 2, bottom: 0, trailing: 0))
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
            ConnectionCardView(callback: {
            }, connectionItem: connectionData.connections[0])
                .previewLayout(.fixed(width: 360, height: 100))
            ConnectionCardView(callback: {
            }, connectionItem: connectionData.connections[1])
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 360, height: 100))
        }
        #endif
    }
}
#endif
