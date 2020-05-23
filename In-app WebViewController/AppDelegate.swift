//
//  AppDelegate.swift
//  In-app WebViewController
//
//  Created by Vy Nguyen on 4/9/20.
//  Copyright © 2020 VVLab. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIFont.familyNames.forEach({ familyName in
            let fontNames = UIFont.fontNames(forFamilyName: familyName)
            print(familyName, fontNames)
        })
        return true
    }


}

