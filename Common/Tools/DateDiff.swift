//
//  DateDiff.swift
//  claft
//
//  Created by zfu on 2022/3/26.
//

import Foundation

extension Date {
    var ISO8601Str: String {
        get {
            let dateformatter = ISO8601DateFormatter()
            let date = Date()
            return dateformatter.string(from: date)
        }
    }
}

extension Date {
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second

        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
    var updateStr : String {
        get {
            let interval = Date() - self
            if let second = interval.second, second < 120 {
                if second == 0 {
                    return ""
                }
                return String(format:"%d seconds ago".localized, arguments: [second])
            }
            if let minute = interval.minute, minute < 90 {
                return String(format:"%d minutes ago".localized, arguments: [minute])
            }
            if let hour = interval.hour, hour < 36 {
                return String(format:"%d hours ago".localized, arguments: [hour])
            }
            if let day = interval.day, day < 60 {
                return String(format:"%d days ago".localized, arguments: [day])
            }
            if let month = interval.month {
                return String(format:"%d months ago".localized, arguments: [month])
            }
            return ""
        }
    }
}
