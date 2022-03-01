//
//  claftApp.swift
//  claft
//
//  Created by zfu on 2021/11/29.
//

import SwiftUI

@main
struct claftApp: App {
    @ObservedObject var serverModel:ServerModel = ServerModel()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(serverModel)
                .onAppear {
                    serverModel.loadServers()
                }
        }
    }
}
