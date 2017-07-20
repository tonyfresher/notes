//
//  AppDelegate.swift
//  Notes
//
//  Created by Anton Fresher on 11.07.17.
//  Copyright © 2017 Anton Fresher. All rights reserved.
//

import UIKit
import CoreData
import CocoaLumberjack

let ddloglevel = DDLogLevel.debug

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // MARK: - Main manager of Core Data for application
    var coreDataManager = CoreDataManager(modelName: "Notes", completion: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // MARK: Injecting Core Data manager to ViewControllers
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if let viewController = storyboard.instantiateViewController(withIdentifier: "List") as? ListTableViewController {
            viewController.coreDataManager = coreDataManager
        }
        
        if let viewController = storyboard.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            viewController.coreDataManager = coreDataManager
        }
        
        // MARK: CocoaLumberjack configuration
        DDLog.add(DDTTYLogger.sharedInstance)
        DDLog.add(DDASLLogger.sharedInstance)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        coreDataManager.saveChanges()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        coreDataManager.saveChanges()
    }

}

