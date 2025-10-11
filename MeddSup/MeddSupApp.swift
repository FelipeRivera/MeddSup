//
//  MeddSupApp.swift
//  MeddSup
//
//  Created by Felipe Rivera on 3/09/25.
//

import SwiftUI
import FirebaseCore
import FirebaseCrashlytics

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        return true
    }
}

@main
struct MeddSupApp: App {
    @StateObject private var splashScreenManager = SplashScreenManager()
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if splashScreenManager.isShowingSplash {
                    SplashScreenView()
                        .transition(.opacity)
                } else {
                    ContentView()
                        .transition(.opacity)
                }
            }
            .environmentObject(splashScreenManager)
        }
    }
}
