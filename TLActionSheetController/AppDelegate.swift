//
//  AppDelegate.swift
//  TLActionSheet
//
//  Created by Terry Lewis on 8/10/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        self.window = UIWindow(frame: UIScreen.main.bounds)
        guard let window = self.window else {
            return false
        }

        window.backgroundColor = UIColor.white
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()

        return true
    }


}

