//
//  ordersViewModel.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/11/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

class ordersViewModel: ObservableObject {
    @Published var orders = [Order]()
    @Published var isLoading = true
    private var db = Firestore.firestore()
    
    func loadOrders() {
        db.collection("orders")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else{
                    self.isLoading = false
                    return
                }
                
                self.orders = documents.compactMap { doc -> Order? in
                    try? doc.data(as: Order.self)
                    
                    
                }
                self.isLoading = false
                
            }
    }
}
