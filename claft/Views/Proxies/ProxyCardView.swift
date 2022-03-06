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
        ZStack {
            VStack() {
                HStack {
                    Text("\(proxy.name)")
                        .font(.system(size: 10))
                    Spacer()
                }
                HStack {
                    Text("\(proxy.type)")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding()
            if let delay = proxy.history.last?.delay {
                if delay > 0 && delay < 100 {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8))
                        .position(x: rect.width - 8, y: 16)
                        .foregroundColor(.green)
                } else if delay < 1000 {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8))
                        .position(x: rect.width - 8, y: 16)
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "circle.fill")
                        .font(Font.system(size: 8))
                        .position(x: rect.width - 8, y: 16)
                        .foregroundColor(.red)
                }
            }
            /*
            if proxy.type != "Selector" {
                HStack {
                    Spacer()
                    Text("\(proxy.history.last?.delay ?? 0) ms")
                        .multilineTextAlignment(.trailing)
                        .font(.system(size: 10))
                        .background(Color.red)
                }
                .fixedSize()
                .frame(width: 120, height: 12)
                .position(x: rect.width - 60, y: rect.height - 14)
            }
             */
        }
    }
    
    var body: some View {
        if selected {
            proxyView
                .background(Color.blue)
                .cornerRadius(8)
                .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
        } else {
            proxyView
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
                .previewLayout(.fixed(width: 140, height: 40))
            ProxyCardView(proxy: proxy)
                .preferredColorScheme(.dark)
                .previewLayout(.fixed(width: 200, height: 40))
        }
    }
}
