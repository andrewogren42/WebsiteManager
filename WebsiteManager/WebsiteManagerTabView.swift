//
//  WebsiteManagerTabView.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/10/26.
//

import SwiftUI

struct WebsiteManagerTabView: View {
    var body: some View {
        TabView {
            messagesUI()
                .tabItem{
                    Image(systemName: "envelope.fill")
                    Text("Messages")
                }
            ordersUI()
                .tabItem{
                    Image(systemName:"cart.fill")
                    Text("Orders")
                }
            listingsUI()
                .tabItem{
                    Image(systemName: "square.and.pencil")
                    Text("Edit")
                }
            SettingsUI()
                .tabItem{
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
    }
}

//#Preview {
//    WebsiteManagerTabView()
//}
