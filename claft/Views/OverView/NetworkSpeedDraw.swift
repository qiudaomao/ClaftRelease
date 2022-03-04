//
//  NetworkSpeedDraw.swift
//  claft
//
//  Created by zfu on 2022/3/2.
//

import SwiftUI

struct NetworkSpeedDraw: View {
    var trafficHistory:[TrafficData] = []
    @State var rect:CGRect = CGRect()
    private let COUNT = 100
    var body: some View {
        ZStack {
            Path() { path in
                path.move(to: CGPoint(x: 0, y:rect.height/2))
                path.addLine(to: CGPoint(x: rect.width, y: rect.height/2))
            }.stroke(Color.gray)
            Path() { path in
                let downs = trafficHistory.map() { $0.down }
                let ups = trafficHistory.map() { $0.up }
                guard let downMax = downs.max(), let upMax = ups.max() else {
                    return
                }
                let max = max(downMax, upMax)
                guard rect.width > 0 && rect.height > 0 else {
                    return
                }
                let YMax = Int((max+2*COUNT-1)/COUNT) * COUNT
                path.move(to: CGPoint(x: rect.width, y: rect.height/2))
                let lines = downs.reversed().map { value -> CGFloat in
                    let y = rect.height/2.0 - rect.height/2.0 * CGFloat(value) / CGFloat(YMax)
                    return y
                }
                for i in 0..<lines.count {
                    let x = rect.width - CGFloat(i)/CGFloat(COUNT) * rect.width
                    let y = lines[i]
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                let x = rect.width - CGFloat(lines.count-1)/CGFloat(COUNT) * rect.width
                path.addLine(to: CGPoint(x: x, y:rect.height/2))
            }.fill(Color.green)
            Path() { path in
                let downs = trafficHistory.map() { $0.down }
                let ups = trafficHistory.map() { $0.up }
                guard let downMax = downs.max(), let upMax = ups.max() else {
                    return
                }
                let max = max(downMax, upMax)
                guard rect.width > 0 && rect.height > 0 else {
                    return
                }
                let YMax = Int((max+2*COUNT-1)/COUNT) * COUNT
                path.move(to: CGPoint(x: rect.width, y: rect.height/2))
                let lines = ups.reversed().map { value -> CGFloat in
                    let y = rect.height/2.0 + rect.height/2.0 * CGFloat(value) / CGFloat(YMax)
                    return y
                }
                for i in 0..<lines.count {
                    let x = rect.width - CGFloat(i)/CGFloat(COUNT) * rect.width
                    let y = lines[i]
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                let x = rect.width - CGFloat(lines.count-1)/CGFloat(COUNT) * rect.width
                path.addLine(to: CGPoint(x: x, y:rect.height/2))
            }.fill(Color.blue)
            /*
            VStack {
                Text("0 B/s")
                Text("0 B/s")
                Text("0 B/s")
                Text("0 B/s")
                Text("0 B/s")
            }
//            .position(x: 0, y: 0)
            .frame(width: 50, alignment: .trailing)
            .background(Color.red)
             */
        }
//        .overlay(
//            Text("0 B/s")
//                .background(Color.red)
//                .frame(width: 50, height: 20, alignment: .trailing)
//                .position(x: 25, y: rect.height/2)
//        )
        .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
    }
}

struct NetworkSpeedDraw_Previews: PreviewProvider {
    static var previews: some View {
        let downs = [400, 50, 100, 200, 300, 400, 500, 300, 100, 300, 700, 100, 400]
        let ups = [40, 50, 10, 20, 30, 40, 50, 100, 10, 30, 70, 10, 40]
        var trafficHistory:[TrafficData] = []
        for i in 0..<downs.count {
            trafficHistory.append(TrafficData(up: ups[i], down: downs[i]))
        }
        return NetworkSpeedDraw(trafficHistory: trafficHistory)
            .frame(width: 600, height: 400)
    }
}
