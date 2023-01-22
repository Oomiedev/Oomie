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
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  var sessionTracker: SessionTracker {
    return SessionTrackerImpl(storage: UserDefaultsStorage())
  }
  
  var soundPackService: SoundPackServiceImpl?
  var archivingService: ArchivingServiceImpl?
  var decodeService: DecodingServiceImpl?
  var networkingService: NetworkingServiceImpl?
  
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
    
    soundPackService?.setupPackage(packsKeys: ["Neon Ocean", "Desert Dawn"]) { [weak self] availability, data in
      guard let self = self else { return }
      if !availability, !data.isEmpty {
        self.isDecoded = false
        self.createPack(data: data)
        self.packs = data
        self.window?.rootViewController = self.createOnboardingScreen()
        
      } else {
        self.fetch()
        self.isDecoded = true
        self.window?.rootViewController = self.sessionTracker.isFirstLaunch ? self.createOnboardingScreen() : self.createHomeScreen()
      }
      //self.soundPackService = nil
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
      self?.fetch()
    }
  }
  
  private func fetch() {
    networkingService = NetworkingServiceImpl()
    guard let url = URL(string: AppConstants.API.baseURL + AppConstants.API.Pack.list) else { return }
    networkingService?.fetchServerPacks(url: url, completion: { [weak self] result in
      switch result {
      case .success(let packs):
        DispatchQueue.main.async {
          var packNames: [String:String] = [:]
          
          packs.data.forEach { model in
            let url = AppConstants.API.baseURL + model.attributes.image.data.attributes.url
            packNames = [model.attributes.title: url]
          }
          
          self?.fetchPack(packs: packNames)
        }
      case .failure(let error):
        print("1111-0 ", error.localizedDescription)
      }
    })
  }
  
  private func fetchPack(packs: [String:String]) {
    self.soundPackService?.setupServerPackage(packsKeys: packs, completion: { availability, serverData in
      
      print("1111-0 Status: ", availability)
    })
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
