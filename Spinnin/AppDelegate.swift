//
//  AppDelegate.swift
//  Spinnin
//
//  Created by carbonyl on 2017-07-13.
//  Copyright © 2017 studio.carbonylgroup. All rights reserved.
//

import UIKit
import GoogleMobileAds


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func applicationDidFinishLaunching(_ application: UIApplication) {
        GADMobileAds.configure(withApplicationID: "ca-app-pub-9841217337381410~5830710687")
    }
}

