//
//  WMButton.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/12/26.
//

import SwiftUI

struct WMButton: View {
    let title: String
    let icon: String
    var color: Color
    var role: ButtonRole? = nil
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer()
            
            Button(role: role, action: action) {
                Label(title, systemImage: icon)
                    .frame(width: 250, height: 50)
            }
            .buttonStyle(.bordered)
            .tint(color)
            
            Spacer()
        }
    }
}
