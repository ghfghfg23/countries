//
//  AppDelegate.swift
//  Countries
//
//  Created by Andrey Ryabov on 26/10/2018.
//  Copyright © 2018 Andrey Ryabov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coordinator: Coordinator = {
        guard let nvc = window?.rootViewController as? UINavigationController else {
            fatalError("Window's root view controller should be UINavigationController at startup.")
        }
        return Coordinator(navigationController: nvc)
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        coordinator.begin()
        return true
    }
}
