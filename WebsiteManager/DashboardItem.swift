//
//  listingsButton.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/12/26.
//

import SwiftUI

struct DashboardItem: View {
    let title: String
    let description: String
    let icon: String?
    let color: Color
    let action: () -> Void
    
    init(
            title: String,
            description: String,
            icon: String? = nil, // Default set to nil
            color: Color,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.description = description
            self.icon = icon
            self.color = color
            self.action = action
        }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                // Large Icon
                
                if let icon{
                    Image(systemName: icon)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(color)
                        .frame(width: 60)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    // Big Title
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    // Small Description
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 150, maxHeight: 250)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(15)
        }
        .padding(.horizontal)
    }
}
