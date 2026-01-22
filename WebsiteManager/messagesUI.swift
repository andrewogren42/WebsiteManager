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
    @State private var isLoading = true
    
    var body: some View {
        NavigationStack {
            Group{
                if isLoading {
                    ProgressView("Loading Messages...")
                        .controlSize(.large)
                        .font(.title2)
                } else if messages.isEmpty {
                    Text("You are all caught up on messages!")
                        .font(.title2)
                        .foregroundColor(.secondary)
                } else {
                    List(messages) { (message: Message) in
                        DashboardItem(title: "\(message.name)'s Message",
                                      description: "\(message.formattedDate)\n \(message.comment)",
                                      color: .blue
                        ) { selectedMessage = message }
                    }
                }
            }
            .navigationTitle("✉️ Messages")
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
        db.collection("messages")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener{ querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    self.isLoading = false
                    return
                }
                self.messages = documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    let ts = data["timestamp"] as? Timestamp
                    
                    let rawDate = ts?.dateValue() ?? Date()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMMM d, yyyy h:mm a"
                    
                    let dateString = formatter.string(from: rawDate)
                    
                    return Message(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "Unknown",
                        number: data["phone"] as? String ?? "No Phone",
                        email: data["email"] as? String ?? "No Email",
                        comment: data["comments"] as? String ?? "",
                        timestamp: rawDate,
                        formattedDate: dateString
                    )
                }
                
                self.isLoading = false
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
                    dismiss()
                }
                .font(.headline)
            }
            
            Divider()
            
            Section(header: Text("Information").font(.title2)){
                Text("Phone Number: \(message.number)")
                    .font(.subheadline)
                Text("Email: \(message.email)")
                    .font(.subheadline)
                Text("Sent At: \(message.formattedDate)")
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
        db.collection("messages").document(message.id).delete()
        dismiss()
    }
}

//#Preview {
//    messagesUI()
//}
