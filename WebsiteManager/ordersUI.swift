//
//  ordersUI.swift
//  ScentsOfHope
//
//  Created by Andrew Ogren on 1/4/26.
////

import SwiftUI
import FirebaseFirestore

struct ordersUI: View {
    @StateObject var viewModel = ordersViewModel()
    @State private var selectedOrder: Order? = nil
    
    var body: some View {
        NavigationStack{
            List(viewModel.orders) { order in
                DashboardItem(title: "\(order.name)'s Order",
                              description: "Address: \(order.address.street) Email: \(order.email)\n Order bought at: \(order.timestamp.formatted(date: .abbreviated, time: .shortened))",
                              color: .blue
                ) { selectedOrder = order }
            }

            .navigationTitle("🛍️ Orders")
            .onAppear {
                viewModel.loadOrders()
            }
            .sheet(item: $selectedOrder) {order in
                OrderDetailedView(order: order)
            }
                             
        }
    }
}

struct OrderDetailedView: View {
    let order: Order
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteWarning = false
    
    var body: some View{
        NavigationStack{
            ScrollView {
                VStack(alignment: .leading){
                    Text("\(order.name)'s Order")
                        .font(.title)
                        .bold()
                    Text("Address: \(order.address.street)")
                    if !order.address.unit.isEmpty {
                        Text("APT: \(order.address.unit)")
                    }
                    Text("Zipcode: \(order.address.zip)")
                    Text("\(order.address.city), \(order.address.state) \(order.address.country)")
                    Text("Email: \(order.email)")
                    Text("Total Price: $\(order.paypalTotal, specifier: "%.2f")")
                    Text("Order bought at: \(order.timestamp.formatted(date: .abbreviated, time: .shortened))")
                    
                    ForEach(0..<order.items.count, id: \.self) { index in
                        // Grab the item using the index
                        let item = order.items[index]
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Item Number: \(index + 1)")
                                .fontWeight(.bold)
                            
                            Text("Name: \(item.name)")
                            Text("Price: \(item.price, specifier: "%.2f")")
                            Text("Quantity: \(item.quantity)")
                            
                            Divider()
                        }
                        .padding(.top, 20)
                    }
                    HStack {
                        
                        Spacer()
                        
                        Button(role: .destructive) {
                            showingDeleteWarning = true
                        } label: {
                            Label("Delete Message", systemImage: "trash")
                                .frame(width: 250, height: 50)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        
                        Spacer()
                    }
                    .padding(.top, 200)
                    
                    
                }
                .padding()
                .toolbar {
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .tint(.blue)
                }
            }
        }
        .confirmationDialog(
            "Are you sure you want to delete this order?",
            isPresented: $showingDeleteWarning,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteOrder(order)
            }
            Button("Cancel", role: .none) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    func deleteOrder(_ order: Order) {
        guard let documentId = order.id else {
            print("Error: Document ID not found")
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("orders").document(documentId).delete { error in
            if let error = error {
                print("Error deleting: \(error.localizedDescription)")
            } else {
                dismiss()
            }
        }
    }
}

#Preview {
    ordersUI()
}
