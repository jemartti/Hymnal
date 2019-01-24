//
//  AppDelegate.swift
//  Hymnal
//
//  Created by Jacob Marttinen on 4/30/17.
//  Copyright © 2017 Jacob Marttinen. All rights reserved.
//

import UIKit

// MARK: - AppDelegate: UIResponder, UIApplicationDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: Properties
    
    var window: UIWindow?
    let stack = CoreDataStack(modelName: "Model")!
    var theme: Constants.Themes = .light
    var hymnFontSize: CGFloat!
    
    // MARK: UIApplicationDelegate
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        saveState()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveState()
    }
    
    func saveState() {
        stack.save()
    }
}
