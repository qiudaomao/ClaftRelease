//
//  OverView.swift
//  claft
//
//  Created by zfu on 2022/3/2.
//

import SwiftUI
import Combine

struct OverView: View {
    @EnvironmentObject var serverModel:ServerModel
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    @State var trafficHistory:[TrafficData] = []
    @State private var cancelables = Set<AnyCancellable>()
    @State private var trafficCancellable: AnyCancellable? = nil
    var body: some View {
        VStack(alignment: .leading) {
            #if os(iOS)
            if horizontalSizeClass != .compact {
                ServerListView()
            }
            #else
            ServerListView()
            #endif
            VStack {
                Spacer()
                NetworkSpeedDraw(trafficHistory: trafficHistory)
                #if os(tvOS)
                    .frame(maxHeight: 400)
                #else
                    .frame(maxHeight: 200)
                #endif
                Spacer()
            }
            #if os(macOS)
            .padding(EdgeInsets(top: 0, leading: 30, bottom: 30, trailing: 30))
            #else
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 30, trailing: 8))
            #endif
        }
        .navigationTitle("OverView")
        .onAppear {
            serverModel.$currentServerIndex.sink { idx in
                self.trafficHistory = []
                let server = serverModel.servers[idx]
                trafficCancellable = server.websockets?.trafficWebSocket.$trafficHistory.sink(receiveValue: { history in
                    self.trafficHistory = history
                })
            }.store(in: &cancelables)
        }
        .onDisappear {
            cancelables.removeAll()
        }
    }
}

struct OverView_Previews: PreviewProvider {
    static var previews: some View {
        let serverModel = ServerModel()
        return OverView().environmentObject(serverModel)
    }
}
