//
//  WebsiteManagerApp.swift
//  WebsiteManager
//
//  Created by Andrew Ogren on 1/10/26.
//

import SwiftUI
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      
      return true
  }
}

@main
struct WebsiteManager: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @Environment(\.scenePhase) var scenePhase
    @StateObject var auth = AuthManager()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isAuthenticated {
                    WebsiteManagerTabView()
                } else {
                    logInView()
                }
            }
            
            .environmentObject(auth)
            
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    checkSessionTimeout()
                } else if newPhase == .background {
                    UserDefaults.standard.set(Date(), forKey: "lastSession")
                }
            }
        }
    }
    
    func checkSessionTimeout() {
        guard let lastActive = UserDefaults.standard.object(forKey: "lastSession") as? Date else { return }
        
        let fourHoursInSeconds: TimeInterval = 4 * 60 * 60
        let timeElapsed = Date().timeIntervalSince(lastActive)
        
        if auth.isAuthenticated && timeElapsed >= fourHoursInSeconds {
            auth.logout()
            UserDefaults.standard.removeObject(forKey: "lastSession")
        }
    }
}
