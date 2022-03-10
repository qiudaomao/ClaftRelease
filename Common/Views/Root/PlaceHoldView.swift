//
//  PlaceHoldView.swift
//  claft
//
//  Created by zfu on 2022/2/27.
//

import SwiftUI

struct PlaceHoldView: View {
    @EnvironmentObject var serverModel:ServerModel
#if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
#endif
    var body: some View {
        #if os(iOS)
        if horizontalSizeClass == .compact {
            VStack(alignment: .leading) {
                ServerListView().environmentObject(serverModel)
                Text("PlaceHoldView")
            }
        } else {
            Text("PlaceHoldView")
        }
        #else
        VStack(alignment: .leading) {
            ScrollView {
                ServerListView().environmentObject(serverModel)
                Text("PlaceHoldView")
            }
        }
        .navigationTitle("PlaceHolder")
        #endif
    }
}

struct PlaceHoldView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceHoldView()
    }
}
