//
//  SpecificCornerShape.swift
//  claft
//
//  Created by zfu on 2021/12/3.
//

import Foundation
import SwiftUI

extension View {
    func clipCorners(
        topLeft: CGFloat = 0,
        bottomLeft: CGFloat = 0,
        topRight: CGFloat = 0,
        bottomRight: CGFloat = 0
    ) -> some View {
        clipShape(
            SpecificCornerShape(
                topLeft: topLeft,
                bottomLeft: bottomLeft,
                topRight: topRight,
                bottomRight: bottomRight
            )
        )
    }
}

struct SpecificCornerShape: Shape {
    var topLeft: CGFloat = 0
    var bottomLeft: CGFloat = 0
    var topRight: CGFloat = 0
    var bottomRight: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX
        let maxY = rect.maxY

        let path = UIBezierPath()
        path.move(to: CGPoint(x: minX + topLeft, y: minY))
        path.addLine(to: CGPoint(x: maxX - topRight, y: minY))
        path.addArc(
            withCenter: CGPoint(x: maxX - topRight, y: minY + topRight),
            radius: topRight,
            startAngle: CGFloat(3 * Double.pi / 2),
            endAngle: 0,
            clockwise: true
        )
        path.addLine(to: CGPoint(x: maxX, y: maxY - bottomRight))
        path.addArc(
            withCenter: CGPoint(x: maxX - bottomRight, y: maxY - bottomRight),
            radius: bottomRight,
            startAngle: 0,
            endAngle: CGFloat(Double.pi / 2),
            clockwise: true
        )
        path.addLine(to: CGPoint(x: minX + bottomLeft, y: maxY))
        path.addArc(
            withCenter: CGPoint(x: minX + bottomLeft, y: maxY - bottomLeft),
            radius: bottomLeft,
            startAngle: CGFloat(Double.pi / 2), endAngle: CGFloat(Double.pi), clockwise: true)
        path.addLine(to: CGPoint(x: minX, y: minY + topLeft))
        path.addArc(
            withCenter: CGPoint(x: minX + topLeft, y: minY + topLeft),
            radius: topLeft,
            startAngle: CGFloat(Double.pi),
            endAngle: CGFloat(3 * Double.pi / 2),
            clockwise: true
        )
        path.close()
        return Path(path.cgPath)
    }
}

