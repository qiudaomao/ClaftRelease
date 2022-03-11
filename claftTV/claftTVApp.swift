//
//  claftTVApp.swift
//  claftTV
//
//  Created by zfu on 2022/3/6.
//

import SwiftUI

@main
struct claftTVApp: App {
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
