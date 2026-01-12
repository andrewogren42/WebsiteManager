//
//  messagesUI.swift
//  ScentsOfHope
//struct Message: Identifiable {
//let id = UUID()
//let name: String
//let phoneNumber: String
//let email:String
//let content:String
//}
//  Created by Andrew Ogren on 1/4/26.
//

import SwiftUI
import FirebaseFirestore

struct messagesUI: View {
    
    @State private var messages: [Message] = []
    @State private var selectedMessage: Message? = nil
    var body: some View {
            NavigationStack {
                List(messages) { (message: Message) in
                    DashboardItem(title: "\(message.name)'s Message",
                                  description: "Phone Number: \(message.number)\n Email: \(message.email)\n Comment: \(message.comment)",
                                  color: .blue
                    ) { selectedMessage = message }
                }
                .navigationTitle("✉️ Messages")
                // Present the modal when selectedMessage is not nil
                .sheet(item: $selectedMessage) { message in
                    MessageDetailView(message: message)
                }
                
                .onAppear {
                    listenForWebMessage()
                }
            }
        }
    
    func listenForWebMessage() {
        let db = Firestore.firestore()
        db.collection("notifications")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener{ querySnapshot, error in
                guard let documents = querySnapshot?.documents else {return}
                self.messages = documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    let ts = data["timestamp"] as? Timestamp
                    
                    return Message(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        number: data["phone"] as? String ?? "No Phone",
                        email: data["email"] as? String ?? "No Email",
                        comment: data["comments"] as? String ?? "",
                        timestamp: ts?.dateValue() ?? Date()
                    )
                }
            }
    }
}

struct MessageDetailView: View {
    let message: Message
    @Environment(\.dismiss) var dismiss
    @State private var showingDeleteWarning = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 40) {
            HStack {
                Text("\(message.name)'s Message")
                    .font(.title)
                    .bold()
                Spacer()
                Button("Close") {
                    dismiss()  // closes the modal
                }
                .font(.headline)
            }
            
            Divider()
            
            Section(header: Text("Information").font(.title3)){
                Text("Phone Number: \(message.number)")
                    .font(.subheadline)
                Text("Email: \(message.email)")
                    .font(.subheadline)
            }
            
            Divider()
            
            Section(header: Text("\(Text(message.name).bold())'s Message")) {
                
                Text("\(message.comment)")
                    .font(.body)
            }
            Spacer()
            
            HStack {
                
                Spacer()
                
                Button(role: .destructive) {
                    showingDeleteWarning = true
                } label: {
                    Label("Delete Message", systemImage: "trash")
                        .frame(width: 250, height: 50)
                }
                .buttonStyle(.bordered) // Base style
                .tint(.red)
                
                Spacer()
            }
        }
        .padding()
        .confirmationDialog(
            "Are you sure you want to delete this message",
            isPresented: $showingDeleteWarning,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteMessage(message)
            }
            Button("Cancel") { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    func deleteMessage(_ message: Message) {
        let db = Firestore.firestore()
        db.collection("notifications").document(message.id).delete()
        dismiss()
    }
}

#Preview {
    messagesUI()
}
