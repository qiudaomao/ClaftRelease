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
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(serverModel)
                .onAppear {
                    serverModel.loadServers()
                }
        }
    }
}
