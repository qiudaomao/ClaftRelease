//
//  String+localized.swift
//  claft
//
//  Created by zfu on 2022/3/10.
//

import Foundation

extension String {
    var localized:String {
        get {
            return NSLocalizedString(self, comment: "")
        }
    }
}
