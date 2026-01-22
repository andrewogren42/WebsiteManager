//
//  logInView.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/15/26.
//

import SwiftUI

struct logInView: View {
    
    @EnvironmentObject var auth: AuthManager
    
    @State private var username = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            
            Text("Log In To Website Manager")
                .font(.title)
            
            Spacer()
            
            TextField("Username", text:$username)
                .padding(.horizontal)
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .textInputAutocapitalization(.never)
                .font(.title2)
            
            Spacer()
                .frame(height: 10)
            
            SecureField("Password", text:$password)
                .padding(.horizontal)
                .frame(height: 70)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .textInputAutocapitalization(.never)
                .font(.title2)
            
            Spacer()
                .frame(height: 40)
            
            if let error = auth.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.title2)
            }
            
            Spacer()
            
            WMButton(title: "Log In", icon: "arrow.right.circle", color: .blue) {
                auth.login(username: username, password: password)
                
                if auth.isAuthenticated {
                    username = ""
                    password = ""
                } else {
                    username = ""
                    password = ""
                }
            }
        }
        .padding()
    }
}

//#Preview {
//    logInView()
//}
