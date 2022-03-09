//
//  NetworkSpeedDraw.swift
//  claft
//
//  Created ddy zfu on 2022/3/2.
//

import SwiftUI

struct NetworkSpeedDraw: View {
    var trafficHistory:[TrafficData] = []
    @State var rect:CGRect = CGRect()
    private let COUNT = 100
    
    func maxSize() -> Int {
        let downs = trafficHistory.map() { $0.down }
        let ups = trafficHistory.map() { $0.up }
        guard let downMax = downs.max(), let upMax = ups.max() else {
            return 0
        }
        let max = max(downMax, upMax)
        guard rect.width > 0 && rect.height > 0 else {
            return 0
        }
        return max
    }
    
    var body: some View {
        #if os(tvOS)
        let scale = 2.0
        #else
        let scale = 1.0
        #endif
        return HStack {
            VStack(alignment: .trailing) {
                ForEach(1..<4) { i in
                    HStack {
                        Spacer()
                        Text("\((self.maxSize()/i).humanReadableByteCountInt())/s")
                            .font(.system(size: 10 * scale))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                HStack {
                    Spacer()
                    Text("0 B/s")
                        .font(.system(size: 10 * scale))
                            .foregroundColor(.secondary)
                }
                ForEach(1..<4) { i in
                    Spacer()
                    HStack {
                        Spacer()
                        Text("\((self.maxSize()/(4-i)).humanReadableByteCountInt())/s")
                            .font(.system(size: 10 * scale))
                            .foregroundColor(.secondary)
                    }
                }
            }
            #if os(tvOS)
            .frame(width: 140)
            #else
            .frame(width: 60 * scale)
            #endif
//            .background(Color.red)
            ZStack {
                Path() { path in
                    path.move(to: CGPoint(x: 0, y:rect.height/2))
                    path.addLine(to: CGPoint(x: rect.width, y: rect.height/2))
                }.stroke(Color.gray)
                Path() { path in
                    path.move(to: CGPoint(x: 0, y:rect.height*0/6+5))
                    path.addLine(to: CGPoint(x: rect.width, y: rect.height*0/6+5))
                }.stroke(Color.gray)
                Path() { path in
                    path.move(to: CGPoint(x: 0, y:rect.height*1/6+5))
                    path.addLine(to: CGPoint(x: rect.width, y: rect.height*1/6+5))
                }.stroke(Color.gray)
                Path() { path in
                    path.move(to: CGPoint(x: 0, y:rect.height*2/6+5))
                    path.addLine(to: CGPoint(x: rect.width, y: rect.height*2/6+5))
                }.stroke(Color.gray)
                Path() { path in
                    path.move(to: CGPoint(x: 0, y:rect.height*4/6-5))
                    path.addLine(to: CGPoint(x: rect.width, y: rect.height*4/6-5))
                }.stroke(Color.gray)
                Path() { path in
                    path.move(to: CGPoint(x: 0, y:rect.height*5/6-5))
                    path.addLine(to: CGPoint(x: rect.width, y: rect.height*5/6-5))
                }.stroke(Color.gray)
                Path() { path in
                    path.move(to: CGPoint(x: 0, y:rect.height*6/6-5))
                    path.addLine(to: CGPoint(x: rect.width, y: rect.height*6/6-5))
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
                        let x = rect.width - CGFloat(i)/CGFloat(COUNT-1) * rect.width
                        let y = lines[i]
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    let x = rect.width - CGFloat(lines.count-1)/CGFloat(COUNT-1) * rect.width
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
                        let x = rect.width - CGFloat(i)/CGFloat(COUNT-1) * rect.width
                        let y = lines[i]
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    let x = rect.width - CGFloat(lines.count-1)/CGFloat(COUNT-1) * rect.width
                    path.addLine(to: CGPoint(x: x, y:rect.height/2))
                }.fill(Color.blue)
            }
            .overlay(Color.clear.modifier(GeometryGetterMod(rect: $rect)))
        }
//        .padding(EdgeInsets(top: 30, leading: 0, bottom: 30, trailing: 0))
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
                .previewLayout(.fixed(width: 600, height: 400))
    }
}
