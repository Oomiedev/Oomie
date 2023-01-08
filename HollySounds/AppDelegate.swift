//
//  AppDelegate.swift
//  HolllySounds
//
//  Created by Ne Spesha on 30.03.22.
//

import UIKit
import AFKit
import AVFoundation
import OomieOnboarding

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
  
  var sessionTracker: SessionTracker {
    return SessionTrackerImpl(storage: UserDefaultsStorage())
  }

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
            guard let self = self else { return }
            self.window?.layer.add(
                CATransition(),
                forKey: nil
            )
            
          self.window?.rootViewController = self.sessionTracker.isFirstLaunch ? self.createOnboardingScreen() : self.createHomeScreen()
        }
        
        return true
    }

  private func createOnboardingScreen() -> UIViewController {
    let onboarding = OnboardingViewController()
    onboarding.delegate = self
    return onboarding
  }
  
  private func createHomeScreen() -> UIViewController {
    let viewController = GalleryViewController()
    return AFDefaultNavigationController(rootViewController: viewController)
  }
}

extension AppDelegate: OnboardingViewControllerDelegate {
  func finishOnboarding() {
    guard let window = self.window else { return }
    
    sessionTracker.isFirstLaunch = false
    
    let transition: () -> Void = { [weak self] in
      window.rootViewController = self?.createHomeScreen()
    }
    
    if let previousController = window.rootViewController {
      UIView.transition(with: window, duration: 0.5, options: [.beginFromCurrentState, .transitionFlipFromRight], animations: transition)
      previousController.dismiss(animated: false) {
        previousController.view.removeFromSuperview()
      }
    } else {
      transition()
    }
  }
}
