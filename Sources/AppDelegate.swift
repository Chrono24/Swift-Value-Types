//
//  AppDelegate.swift
//  Value-Types-at-Chrono24
//
//  Created by Christian Schnorr on 20.08.19.
//  Copyright © 2019 Christian Schnorr. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
//        window.rootViewController = UINavigationController(rootViewController: ReferenceTypeViewController())
        window.rootViewController = UINavigationController(rootViewController: ValueTypeViewController())

        self.window = window

        window.makeKeyAndVisible()

        return true
    }
}
