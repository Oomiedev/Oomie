//
//  AppDelegate.swift
//  HolllySounds
//
//  Created by Ne Spesha on 30.03.22.
//

import UIKit
import AFKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        /*
         */
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let viewController = SplashViewController()
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        /*
         */
        
        SoundManager.shared.initialize()
        
        /*
         */
        
        DataManager.shared.initialize { [weak self] in
            
            self?.window?.layer.add(
                CATransition(),
                forKey: nil
            )
            
            let viewController = GalleryViewController()
            let navigationController = AFDefaultNavigationController(rootViewController: viewController)
            self?.window?.rootViewController = navigationController
        }
        
        return true
    }

}

