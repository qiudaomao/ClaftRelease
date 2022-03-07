//
//  ProxyCardView.swift
//  claft
//
//  Created by zfu on 2022/3/5.
//

import SwiftUI

struct ProxyCardView: View {
    var proxy:ProxyItemData = ProxyItemData()
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
                        .font(.system(size: 10 * scale))
                    Spacer()
                }
                HStack {
                    Text("\(proxy.type)")
                        .font(.system(size: 10 * scale))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            if let delay = proxy.history.last?.delay {
                if delay > 0 && delay < 100 {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
                        .position(x: rect.width - 8 * scale, y: 16 * scale)
                        .foregroundColor(.green)
                } else if delay < 1000 {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
                        .position(x: rect.width - 8 * scale, y: 16 * scale)
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8 * scale))
                        .position(x: rect.width - 8 * scale, y: 16 * scale)
                        .foregroundColor(.red)
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
                .background(Color.blue)
                .cornerRadius(8)
                .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
        } else {
            proxyView
#if os(tvOS)
    .frame(width: 320, height: 100)
#endif
                .background(Material.regularMaterial)
                .cornerRadius(8)
                .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
        }
    }
}

struct ProxyCardView_Previews: PreviewProvider {
    static var previews: some View {
        var proxy = ProxyItemData()
        proxy.name = "节点选择"
        proxy.type = "ShadowSocks"
        proxy.history = [ProxyHistoryData(time: "123", delay: 1024)]
        return Group {
            ProxyCardView(proxy: proxy)
            #if os(tvOS)
                .previewLayout(.fixed(width: 320, height: 80))
            #else
                .previewLayout(.fixed(width: 140, height: 40))
            #endif
            ProxyCardView(proxy: proxy)
                .preferredColorScheme(.dark)
            #if os(tvOS)
                .previewLayout(.fixed(width: 320, height: 80))
            #else
                .previewLayout(.fixed(width: 200, height: 40))
            #endif
        }
    }
}
