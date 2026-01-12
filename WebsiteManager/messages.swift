//
//  messages.swift
//  ScentsOfHope
//
//  Created by Andrew Ogren on 1/4/26.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable {
    let id: String
    let name: String
    let number: String
    let email:String
    let comment:String
    let timestamp: Date
}

func processDocuments(documents: [QueryDocumentSnapshot]) -> [Message] {
    let mappedMessages = documents.compactMap { doc -> Message? in
        let data = doc.data()
        
        // Convert Firebase Timestamp to Swift Date
        let ts = data["timestamp"] as? Timestamp
        let dateValue = ts?.dateValue() ?? Date() // Default to "now" if missing
        
        return Message(
            id: doc.documentID,
            name: data["name"] as? String ?? "",
            number: data["phone"] as? String ?? "",
            email: data["email"] as? String ?? "",
            comment: data["comments"] as? String ?? "",
            timestamp: dateValue
        )
    }
    return mappedMessages
}
