//
//  orders.swift
//  ScentsOfHope
//
//  Created by Andrew Ogren on 1/4/26.
//

import Foundation
import FirebaseFirestore

struct OrderItem: Identifiable, Codable{
    var id = UUID()
    let name:String
    let price:Double
    let quantity: Int
    let img: String?
    
    enum CodingKeys: String, CodingKey {
            case name
            case price
            case quantity
            case img
        }
}

struct Address: Codable{
    let street: String
    let unit: String
    let city: String
    let state: String
    let zip: String
    let country: String
}

struct Order: Identifiable, Codable{
    @DocumentID var id: String?
    let name:String
    let email:String
    let address: Address
    let websiteTotal:Double
    let paypalTotal:Double
    let items: [OrderItem]
    let timestamp: Date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy h:mm a"
        return formatter.string(from: timestamp)
    }
    
}
