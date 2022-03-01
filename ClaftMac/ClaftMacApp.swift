//
//  ClaftMacApp.swift
//  ClaftMac
//
//  Created by zfu on 2022/2/28.
//

import SwiftUI

@main
struct ClaftMacApp: App {
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
