//
//  claftApp.swift
//  claft
//
//  Created by zfu on 2021/11/29.
//

import SwiftUI
import Combine

@main
struct claftApp: App {
    @ObservedObject var serverModel:ServerModel = ServerModel()
    @ObservedObject var connectionOrderModel:ConnectionOrderModel = ConnectionOrderModel()
    @State var cancellables = Set<AnyCancellable>()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(serverModel)
                .environmentObject(connectionOrderModel)
                .onAppear {
                    serverModel.loadServers()
                    connectionOrderModel.loadOrder()
                    connectionOrderModel.$orderMode.sink { value in
                        connectionOrderModel.saveOrder(value)
                    }.store(in: &cancellables)
                }
        }
    }
}
