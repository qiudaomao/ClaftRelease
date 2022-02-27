//
//  ConnectionOrderModel.swift
//  claft
//
//  Created by zfu on 2022/2/27.
//

import Foundation
import Combine

enum ConnectionOrder: Int {
    case none = 0
    case time = 1
    case downloadSize = 2
    case uploadSize = 3
}

class ConnectionOrderModel: ObservableObject {
    @Published var orderMode: ConnectionOrder = .none
    
    func loadOrder() {
        let userDefault = UserDefaults.standard
        if let order = userDefault.value(forKey: "ConnectionOrder") as? Int {
            orderMode = ConnectionOrder(rawValue: order) ?? .none
        }
        print("loadOrder <= \(orderMode)")
    }
    
    func saveOrder() {
        let userDefault = UserDefaults.standard
        userDefault.set(orderMode.rawValue, forKey: "ConnectionOrder")
        print("saveOrder => \(orderMode)")
    }
}