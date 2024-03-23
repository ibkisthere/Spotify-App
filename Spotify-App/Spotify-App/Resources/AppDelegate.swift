//
//  AppDelegate.swift
//  Spotify-App
//
//  Created by Ibukunoluwa Akintobi on 03/01/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let window = UIWindow(frame: UIScreen.main.bounds)
        if AuthManager.shared.isSignedIn {
            window.rootViewController = TabBarViewController()
        } else {
            let navVc = UINavigationController(rootViewController: WelcomeViewController())
            navVc.navigationBar.prefersLargeTitles = true
            navVc.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
            window.rootViewController = navVc
        }
        window.makeKeyAndVisible()
        self.window = window
        
        AuthManager.shared.refreshIfNeeded {
            success in print(success)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}

