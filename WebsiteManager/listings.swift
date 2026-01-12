//
//  listings.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/11/26.
//

import Foundation
import Combine
import FirebaseFirestore


struct Listing: Identifiable, Codable{
    @DocumentID var id: String?
    var name:String
    var price:Double
    var img:String
    var desc:String
    var collection:String
    var sale: Bool
}
