//
//  AppDelegate.swift
//  Check2Venmo
//
//  Created by Joseph Lin on 11/26/14.
//  Copyright (c) 2014 Joseph Lin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        Venmo.startWithAppId("venmo2332", secret: "agWk6kbF3bUZ4Jbzwm6QQ2hznLrkHP3J", name: "Sent via ReceiptScan");
        return true
    }
    
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        if (Venmo.sharedInstance().handleOpenURL(url)) {
            return true;
        }
        return false;
    }
}

