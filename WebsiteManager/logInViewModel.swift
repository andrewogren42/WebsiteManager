//
//  logInViewModel.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/15/26.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
class AuthManager: ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var errorMessage: String? = nil
    
    private var db = Firestore.firestore()
    
    func login(username:String, password:String) {
        errorMessage = nil
        
        if username.isEmpty || password.isEmpty{
            errorMessage = "Please enter both username and password"
            return
        }
        
        db.collection("logIns")
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments { querySnapshot, error in
                
                if let error = error{
                    DispatchQueue.main.async{
                        self.errorMessage = "\(error.localizedDescription)"
                    }
                    return
                }

                guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Incorrect username or password Error 1"
                    }
                    return
                }
                
                let userData = documents[0].data()
                let storedPassword = userData["password"] as? String ?? ""
                
                DispatchQueue.main.async {
                    if storedPassword == password {
                        self.isAuthenticated = true
                    } else {
                        self.isAuthenticated = false
                        self.errorMessage = "Incorrect username or password Error 2"
                    }
                }
                
                
            }
    }
    
    func logout() {
        isAuthenticated = false
        errorMessage = nil
    }
}


