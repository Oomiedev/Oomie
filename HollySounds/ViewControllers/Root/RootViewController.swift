//
//  RootViewController.swift
//  HolllySounds
//
//  Created by Ne Spesha on 30.03.22.
//

import UIKit
import RealmSwift
import AFKit

final class RootViewController: AFDefaultViewController {

    /*
     MARK: -
     */
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var tabBarView: TabBarView!
    
    /*
     MARK: -
     */
    
    private var currentViewController: AFDefaultNavigationController?
    private var controllersCache: [Int: AFDefaultNavigationController] = [:]
    private var settingsNotificationToken: NotificationToken!
    
    /*
     MARK: -
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         */
        
        setupTabBarView()
    }
    
    /*
     MARK: -
     */
    
    private func setupTabBarView() {
        
        /*
         */
        
        tabBarView.tintColor = UIColor(
            named: "Color 7"
        )
        tabBarView.iconsColor = UIColor(
            named: "Color 7"
        )
        
        
        /*
         */
        
        settingsNotificationToken = Settings.current
            .observe(
                keyPaths: ["currentSectionIndex"],
                { [weak self] changes in
                    switch changes {
                    case .change(_, _):
                        DispatchQueue.main.async {
                            self?.updateUI()
                        }
                    case .deleted:
                        self?.settingsNotificationToken.invalidate()
                    case .error(let error):
                        print(error)
                    }
                }
            )
        
        /*
         */
        
        updateUI()
        updateTabBar()
    }
    
    private func updateUI() {
        
        /*
         */
        
        currentViewController?.willMove(toParent: nil)
        currentViewController?.removeFromParent()
        
        currentViewController?.view.removeFromSuperview()
        
        /*
         */
        
        if let navigationController = controllersCache[Settings.current.currentSectionIndex] {
            navigationController.willMove(toParent: self)
            
            containerView.addSubview(navigationController.view)
            navigationController.view.bindToSuperview()
            
            navigationController.didMove(toParent: self)
        } else {
            let controllersMap = [
                GalleryViewController.self,
                ProfileViewController.self
            ]
            
            let viewControllerClass = controllersMap[Settings.current.currentSectionIndex]
            let viewController = viewControllerClass.init()
            let navigationController = AFDefaultNavigationController(rootViewController: viewController)
            addChild(navigationController)
            
            navigationController.willMove(toParent: self)
            
            containerView.addSubview(navigationController.view)
            navigationController.view.bindToSuperview()
            
            navigationController.didMove(toParent: self)
            
            controllersCache[Settings.current.currentSectionIndex] = navigationController
        }
        
        /*
         */
        
        currentViewController = controllersCache[Settings.current.currentSectionIndex]
    }
    
    private func updateTabBar() {
        tabBarView.dataProvider = [
            TabBarViewItem(
                image: UIImage(
                    named: "TabBarWalletIcon"
                ),
                title: "Gallery",
                notificationCount: 0
            ),
            TabBarViewItem(
                image: UIImage(
                    named: "TabBarTodayIcon"
                ),
                title: "Profile",
                notificationCount: 0
            )
        ]
    }

}
