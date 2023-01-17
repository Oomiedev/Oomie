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
  
  var soundPackService: SoundPackServiceImpl?
  var archivingService: ArchivingServiceImpl?
  var decodeService: DecodingServiceImpl?
  
  var onboarding: OnboardingViewController?
  
  var isDecoded: Bool = false
  var packs: [SoundData] = []

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    /*
     */
    
    window = UIWindow(frame: UIScreen.main.bounds)
    
    let viewController = SplashViewController()
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
    
    soundPackService = SoundPackServiceImpl()
    
    soundPackService?.setupPackage { [weak self] availability, data in
      guard let self = self else { return }
      if !availability, !data.isEmpty {
        self.isDecoded = false
        self.createPack(data: data)
        self.packs = data
        self.window?.rootViewController = self.createOnboardingScreen()
        
      } else {
        self.isDecoded = true
        self.window?.rootViewController = self.sessionTracker.isFirstLaunch ? self.createOnboardingScreen() : self.createHomeScreen()
      }
      self.soundPackService = nil
    }
    
    /*
     */
    
    SoundManager.shared.initialize()
    
    /*
     */
    
    //DataManager.shared.initialize(with: nil)
    
    //        DataManager.shared.initialize { [weak self] in
    //            guard let self = self else { return }
    //            self.window?.layer.add(
    //                CATransition(),
    //                forKey: nil
    //            )
    //
    //          self.window?.rootViewController = self.sessionTracker.isFirstLaunch ? self.createOnboardingScreen() : self.createHomeScreen()
    //        }
    
    return true
  }
  
  private func createPack(data: [SoundData]) {
    archivingService = ArchivingServiceImpl()
    archivingService?.unzip(data: data) { [weak self] _ in
      self?.archivingService = nil
    }
  }
  
  private func createOnboardingScreen() -> UIViewController {
    onboarding = OnboardingViewController()
    onboarding?.delegate = self
    return onboarding!
  }
  
  private func createHomeScreen() -> UIViewController {
    decodeService = DecodingServiceImpl()
    let viewModel = GalleryViewModel(decodingService: decodeService, isDecoded: isDecoded, packs: packs)
    let viewController = GalleryViewController()
    viewController.viewModel = viewModel
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
    
    onboarding = nil
  }
}
