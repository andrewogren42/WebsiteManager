//
//  SettingsUI.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/15/26.
//

import SwiftUI

struct SettingsUI: View {
    
    @EnvironmentObject var auth: AuthManager
    
    var body: some View {
        NavigationStack{
            
            Spacer()
            
            WMButton(title: "Log Out", icon: "rectangle.portrait.and.arrow.right", color: .red) {
                
                auth.logout()
            }
            .navigationTitle("Settings ⚙️")
        }
    }
}

//#Preview {
//    SettingsUI()
//}
