//
//  AppDelegate.swift
//  STComponentTools_Example
//
//  Created by stephenchen on 2024/01/26.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let win = UIWindow.init(frame: UIScreen.main.bounds)
        win.backgroundColor = UIColor.white
        self.window = win
        
        
        let tab = UITabBarController()
        var arr: [UIViewController] = [UIViewController]()
        do{
            let nav = UINavigationController.init(rootViewController: ViewController())
            arr.append(nav)
        }
        
        tab.viewControllers = arr
        win.rootViewController = tab
        win.makeKeyAndVisible()
        return true
    }
}

