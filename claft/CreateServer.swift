//
//  CreateServer.swift
//  claft
//
//  Created by zfu on 2021/12/1.
//

import SwiftUI

struct Entry: Identifiable {
    var id = UUID()
    var title:String = ""
    var value:String = ""
    var image:String = ""
    var placeHolder:String = ""
}
struct CreateServer: View {
    var entries:[Entry] = [
        Entry(title: "Host", image: "network", placeHolder: "Domain or IP"),
        Entry(title: "Port", image: "bolt.horizontal.circle", placeHolder: "9090"),
        Entry(title: "Secret", image: "lock.fill", placeHolder: "Optional"),
    ]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var inputValue:String = ""
    var body: some View {
        NavigationView {
            List {
                ForEach(entries) { (entry) in
                    HStack {
                        Image(systemName: entry.image)
                        Text(entry.title)
                            .frame(width: 60)
                        TextField(entry.placeHolder, text: $inputValue)
                            .multilineTextAlignment(.leading)
                    }
                    .padding()
                }
            }
            .navigationTitle("New Server")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            },trailing: Button(action: {
            }) {
                Image(systemName: "square.and.arrow.down")
            })
        }
    }
}

struct CreateServer_Previews: PreviewProvider {
    static var previews: some View {
        CreateServer()
    }
}
