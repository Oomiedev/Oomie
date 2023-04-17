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
import StoreKit

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
  var subscriptionService: SubscriptionServiceImpl?
  
  var onboarding: OnboardingViewController?
  let viewModel = GalleryViewModel()
  let job = Job()

  var packs: [SoundData] = []
  var products: [SKProduct] = []
  var purchaseStatus: Bool?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.main.bounds)
    
    let viewController = SplashViewController()
    window?.rootViewController = viewController
    window?.makeKeyAndVisible()
    
    soundPackService = SoundPackServiceImpl()
    
    if sessionTracker.isFirstLaunch {
      purchaseStatus = false
      soundPackService?.clearOldPackages { [weak self] in
        self?.setupPackage(service: self?.soundPackService)
        self?.subscribe()
      }
    } else {
      self.setupPackage(service: self.soundPackService)
      self.fetchSubscription(animation: false)
    }
    
    self.window?.rootViewController = self.sessionTracker.isFirstLaunch ? self.createOnboardingScreen() : self.createHomeScreen()
    
    SoundManager.shared.initialize()
    return true
  }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if SoundManager.shared.isPlayingNow {
            resignInteruption()
            SoundManager.shared.playingInBackground = false
        } else {
            if SoundManager.shared.pausedViaControlCenter {
                resignInteruption()
                SoundManager.shared.resume()
            }
            
            if SoundManager.shared.playingInBackground {
                SoundManager.shared.resume()
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        if SoundManager.shared.isPlayingNow {
            observeInteruption()
            SoundManager.shared.playingInBackground = true
        }
    }
    
    private func observeInteruption() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(interuption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func interuption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let typeValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else {
            return
        }
        
        if type == .began {
            SoundManager.shared.pause()
        } else if type == .ended {
            if let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    SoundManager.shared.resume()
                }
                else {
                    SoundManager.shared.resume()
                }
            }
        }
    }
    
    private func resignInteruption() {
        NotificationCenter.default.removeObserver(self)
    }
  
  private func subscribe() {
    subscriptionService = SubscriptionServiceImpl()
    subscriptionService?.fetchSubscriptions(identifiers: OomieProProucts.allCases)
    
    subscriptionService?.products = { [weak self] products in
      guard let self = self else { return }
      DispatchQueue.main.async {
        self.products = products
      }
    }
    
    subscriptionService?.paymentComplete = { [weak self] status in
      if status {
        self?.purchaseStatus = true
      }
    }
  }
  
  private func setupPackage(service: SoundPackService?) {
    service?.setupPackage(packsKeys: ["Neon Ocean", "Desert Dawn"], completion: { [weak self] available, soundData in
      guard let self = self else { return }
      if !available, !soundData.isEmpty {
        self.packs.append(contentsOf: soundData)
        self.createPack(data: soundData)
      } else {
        self.fetch()
      }
    })
  }
  
  private func createPack(data: [SoundData]) {
    archivingService = ArchivingServiceImpl()
    archivingService?.unzip(data: data) { [weak self] _ in
      self?.archivingService = nil
      self?.fetch()
      self?.decode()
    }
  }
  
  private func fetch() {
    networkingService = NetworkingServiceImpl()
    guard let url = URL(string: AppConstants.API.baseURL + AppConstants.API.Pack.list) else { return }
    networkingService?.fetchServerPacks(url: url, completion: { [weak self] result in
      switch result {
      case .success(let packs):
        DispatchQueue.main.async {
          var packNames: [PackURL] = []
          packs.data.forEach { model in
            let imageURL = AppConstants.API.baseURL + model.attributes.image.data.attributes.url
            let contentURL = AppConstants.API.baseURL + model.attributes.content.data.attributes.url
            let serverPack = PackURL(name: model.attributes.title,
                                     imageURL: imageURL,
                                     contentURL: contentURL)
            packNames.append(serverPack)
          }
          
          self?.fetchPack(packs: packNames)
        }
      case .failure(let error):
        print("1111-0 ", error.localizedDescription)
      }
    })
  }
  
  private func fetchPack(packs: [PackURL]) {
    self.soundPackService?.setupServerPackage(packsKeys: packs, completion: {[weak self] _, _ in
      self?.soundPackService = nil
      if let vm = self?.viewModel, let job = self?.job {
        vm.observe(job: job)
        job.fetchingProcess = true
      }
    })
  }
  
  private func decode() {
    if !self.packs.isEmpty {
      decodeService = DecodingServiceImpl()
      viewModel.observe(job: job)
      job.loadingProccess = true
      decodeService?.decodeLoops(packs: self.packs, completion: {[weak self] _ in
        self?.job.loadingProccess = false
      })
    }
  }
  
  private func fetchSubscription(animation: Bool) {
    
    let status = checkForProPakage()
    
    if status {
      subscriptionService = SubscriptionServiceImpl()
      subscriptionService?.fetchSubscriptions(identifiers: OomieProProucts.allCases)
      
      subscriptionService?.products = { [weak self] products in
        guard let self = self else { return }
        self.products = products
        DispatchQueue.main.async {
          let subscriptionScreen = self.createSubscriptionScreen(products: products, isFromOnboarding: false)
          subscriptionScreen.modalPresentationStyle = .overCurrentContext
          self.window?.rootViewController?.present(subscriptionScreen, animated: animation)
        }
      }
      
      subscriptionService?.paymentComplete = { [weak self] status in
        if status {
          self?.viewModel.updateSubscription?()
        }
      }
    }
  }
  
  func checkSubscription() {
    if products.isEmpty {
      fetchSubscription(animation: true)
    } else {
      let subscriptionScreen = self.createSubscriptionScreen(products: products, isFromOnboarding: false)
      subscriptionScreen.modalPresentationStyle = .overCurrentContext
      self.window?.rootViewController?.present(subscriptionScreen, animated: true)
    }
  }
  
  private func createOnboardingScreen() -> UIViewController {
    onboarding = OnboardingViewController()
    onboarding?.delegate = self
    return UINavigationController(rootViewController: onboarding!)
  }
  
  private func createHomeScreen() -> UIViewController {
    let viewController = GalleryViewController()
    viewController.sessionTracker = sessionTracker
    viewController.viewModel = viewModel
    return AFDefaultNavigationController(rootViewController: viewController)
  }
  
  private func createSubscriptionScreen(products: [SKProduct], isFromOnboarding: Bool) -> UIViewController {
    let vc = SubscriptionViewController(products: products, isFromOnboarding: isFromOnboarding)
    
    vc.selectProduct = { [weak self] product in
      self?.subscriptionService?.buy(product: product)
    }
    
    vc.hasClosed = { [weak self] status in
      self?.subscriptionService?.viewDismissed(status: status)
    }
    
    vc.dismissed = { [weak self] in
      self?.updateView()
    }
    
    subscriptionService?.dismissView = {
      vc.dismiss()
    }
    
    return vc
  }
  
  private func updateView() {
    guard let window = self.window else { return }
    let transition: () -> Void = { [weak self] in
      window.rootViewController = self?.createHomeScreen()
    }
    
    if let previousController = window.rootViewController {
      previousController.dismiss(animated: false) {
        previousController.view.removeFromSuperview()
        transition()
      }
    } else {
      transition()
    }
    
    if purchaseStatus ?? false {
      viewModel.updateSubscription?()
    }
  }
  
  private func checkForProPakage() -> Bool {
    var status: Bool = true
    do {
      let realm = try Realm()
      let objects = realm.objects(Package.self)
      
      for obj in objects {
        if obj.status == .pro {
          status = true
        } else {
          status = false
        }
      }
      
    } catch let error {
      print("Error: ", error)
    }
    
    return status
  }
}

extension AppDelegate: OnboardingViewControllerDelegate {
  func finishOnboarding() {
    sessionTracker.isFirstLaunch = false
    sessionTracker.isPlayedBefore = false
    if !products.isEmpty {
      let subscriptionScreen = self.createSubscriptionScreen(products: products, isFromOnboarding: true)
      onboarding?.navigationController?.pushViewController(subscriptionScreen, animated: true)
      onboarding = nil
    } else {
      openMainScreen()
      onboarding = nil
    }
  }
  
  private func openMainScreen() {
    guard let window = self.window else { return }
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
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      self.fetchSubscription(animation: true)
    }
  }
}

struct PackURL {
  let name: String
  let imageURL: String
  let contentURL: String
}
