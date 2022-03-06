//
//  Formater.swift
//  claft
//
//  Created by zfu on 2021/12/8.
//

import Foundation

extension Int {
    func humanReadableByteCount() -> String {
        let bytes = self
        if (bytes < 1000) { return "\(bytes) B" }
        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1000, Double(exp))
        return String(format: "%.1f %@", number, unit)
    }
    
    func humanReadableByteCountInt() -> String {
        let bytes = self
        if (bytes < 1000) { return "\(bytes) B" }
        let exp = Int(log2(Double(bytes)) / log2(1000.0))
        let unit = ["KB", "MB", "GB", "TB", "PB", "EB"][exp - 1]
        let number = Double(bytes) / pow(1000, Double(exp))
        return String(format: "%.0f %@", number, unit)
    }
}
