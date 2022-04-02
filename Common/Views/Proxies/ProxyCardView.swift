//
//  ProxyCardView.swift
//  claft
//
//  Created by zfu on 2022/3/5.
//

import SwiftUI

struct ProxyCardView: View {
    @Binding var proxy:ProxyItemData// = ProxyItemData()
    var selected:Bool = false
    @State var rect:CGRect = .zero

    var proxyView: some View {
        #if os(tvOS)
        let scale = 2.0
        #else
        let scale = 1.0
        #endif
        return ZStack {
            VStack() {
                HStack {
                    Text("\(proxy.name)")
                        .lineLimit(1)
                        .font(.system(size: 10 * scale))
                    Spacer()
                }
                HStack {
                    Text("\(proxy.type)")
                        .lineLimit(1)
                        .font(.system(size: 10 * scale))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            if let delay = proxy.history.last?.delay {
                if delay < 1 {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
                        .position(x: rect.width - 8 * scale, y: 16 * scale)
                        .foregroundColor(.gray)
                } else if delay > 0 && delay < 300 {
                        Image(systemName: "circle.fill")
                            .font(Font.system(size: 8 * scale))
                            .position(x: rect.width - 8 * scale, y: 16 * scale)
                            .foregroundColor(.green)
                        Text("\(delay) ms")
                            .font(.system(size: 10))
                            .frame(width: 80, alignment: .trailing)
                            .position(x: rect.width - 44, y: rect.height - 22)
                            .foregroundColor(.green)
                } else if delay < 1500 {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
                        .position(x: rect.width - 8 * scale, y: 16 * scale)
                        .foregroundColor(.orange)
                    Text("\(delay) ms")
                        .font(.system(size: 10))
                        .frame(width: 80, alignment: .trailing)
                        .position(x: rect.width - 44, y: rect.height - 22)
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
                        .position(x: rect.width - 8 * scale, y: 16 * scale)
                        .foregroundColor(.red)
                    Text("\(delay) ms")
                        .font(.system(size: 10))
                        .frame(width: 80, alignment: .trailing)
                        .position(x: rect.width - 44, y: rect.height - 22)
                        .foregroundColor(.red)
                }
                if let time = proxy.history.last?.time {
                    let date: Date? = {
                        do {
                            let regex = try NSRegularExpression(pattern: "\\.[0-9]+Z$")
                            let regex1 = try NSRegularExpression(pattern: "\\.[0-9]+\\+")
                            let str = regex.stringByReplacingMatches(in: time, range: NSMakeRange(0, time.lengthOfBytes(using: .utf8)), withTemplate: "Z")
                            let
                            str1 = regex1.stringByReplacingMatches(in: str, range: NSMakeRange(0, str.lengthOfBytes(using: .utf8)), withTemplate: "+")
                            return ISO8601DateFormatter().date(from: str1)
                        } catch {
                            print("update at regex error: \(error)")
                        }
                        return nil
                    }()
                    if let str = date?.updateStr {
                        HStack {
                            Spacer()
                            Text("\(str)")
                                .font(.system(size: 8 * scale))
                                .foregroundColor(.secondary)
                                .frame(width: 120, alignment: .trailing)
                                .position(x: rect.width - 72, y: rect.height - 10)
                        }
                    }
                }
            }
        }
    }
    
    var body: some View {
        if selected {
            proxyView
#if os(tvOS)
    .frame(width: 320, height: 100)
#endif
                .background(Color.accentColor)
                .cornerRadius(8)
                .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
        } else {
            proxyView
#if os(tvOS)
    .frame(width: 320, height: 100)
#endif
//                .background(Material.regularMaterial)
                .modifier(CardBackgroundModifier())
                .cornerRadius(8)
                .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
        }
    }
}

struct ProxyCardView_Previews: PreviewProvider {
    static var previews: some View {
        @State var proxy = ProxyItemData()
        proxy.name = "节点选择"
        proxy.type = "ShadowSocks"
        proxy.history = [ProxyHistoryData(time: "2022-03-26T00:52:39.926268244Z", delay: 1024)]
        return Group {
            ProxyCardView(proxy: $proxy)
            #if os(tvOS)
                .previewLayout(.fixed(width: 320, height: 80))
            #elseif os(macOS)
                .previewLayout(.fixed(width: 280, height: 180))
            #else
                .previewLayout(.fixed(width: 140, height: 40))
            #endif
            ProxyCardView(proxy: $proxy)
                .preferredColorScheme(.dark)
            #if os(tvOS)
                .previewLayout(.fixed(width: 320, height: 80))
            #elseif os(macOS)
                .previewLayout(.fixed(width: 280, height: 180))
            #else
                .previewLayout(.fixed(width: 200, height: 40))
            #endif
        }
    }
}
