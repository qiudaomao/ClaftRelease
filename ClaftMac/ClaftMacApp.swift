//
//  ClaftMacApp.swift
//  ClaftMac
//
//  Created by zfu on 2022/2/28.
//

import SwiftUI
import Combine

@main
struct ClaftMacApp: App {
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
