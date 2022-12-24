//
//  GalleryViewController.swift
//  HollySounds
//
//  Created by Ne Spesha on 17.04.22.
//

import UIKit
import AFKit
import RealmSwift
import AVFoundation

final class GalleryViewController: AFDefaultViewController {

    /*
     MARK: -
     */
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var videoContainerView: UIView!
    
    /*
     MARK: -
     */
    
    private var dataProvider: Results<Package>!
    private var playerViewController: PlayerViewController?
    
    private let url = Bundle.main.url(forResource: "GalleryBackgroundTop", withExtension: "mp4")
    private var playerLayer: AVPlayerLayer!
    private var playerLooper: AVPlayerLooper!
    private var queuePlayer: AVQueuePlayer!
    
    /*
     MARK: -
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupDataProvider()
        setupCollectionView()
        playVideo()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let value = playerLayer {
            value.frame = videoContainerView.bounds
        }
    }
    
    func setupCollectionView() {
        
        /*
         */
        
        collectionView.register(
            UINib(
                nibName: PackageCell.CellID,
                bundle: .main
            ),
            forCellWithReuseIdentifier: PackageCell.CellID
        )
        
        collectionView.register(
            UINib(
                nibName: GalleryHeaderView.HeaderID,
                bundle: .main
            ),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: GalleryHeaderView.HeaderID
        )
        
        /*
         */
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .estimated(100)
            )
        )
        
        item.contentInsets = NSDirectionalEdgeInsets(
            top: 12 * SizeFactor,
            leading: 8 * SizeFactor,
            bottom: 12 * SizeFactor,
            trailing: 8 * SizeFactor
        )
        
        /*
         */
        
        let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        /*
         */
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(100)
            ),
            subitems: [item]
        )
        group.contentInsets = NSDirectionalEdgeInsets(
            top: 12 * SizeFactor,
            leading: 8 * SizeFactor,
            bottom: 12 * SizeFactor,
            trailing: 8 * SizeFactor
        )
        
        /*
         */
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [headerItem]
        section.interGroupSpacing = 24 * SizeFactor
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 0,
            bottom: 32 * SizeFactor,
            trailing: 0
        )
        
        /*
         */
           
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupDataProvider() {
        let realm = try! Realm()
        dataProvider = realm.objects(Package.self)
    }

    private func showPlayer(for package: Package) {
        
        /*
         */
        
        SoundManager.shared.stopCurrentPreview()
        
        /*
         */
        
        guard
            let delegate = UIApplication.shared.delegate as? AppDelegate,
            let window = delegate.window,
            let defaultNavigationController = window.rootViewController as? AFDefaultNavigationController,
            let rootViewController = defaultNavigationController.viewControllers.first
        else { return }
        
        /*
         */
        
        let viewController = PlayerViewController()
        viewController.package = package
        
        rootViewController.addChild(viewController)
        viewController.view.frame = rootViewController.view.frame
        viewController.willMove(toParent: rootViewController)

        UIView.transition(
            with: rootViewController.view,
            duration: 0.4,
            options: [
                .transitionFlipFromLeft
            ]
        ) {
            rootViewController.view.addSubview(viewController.view)
        } completion: { _ in
            viewController.didMove(toParent: rootViewController)
        }
        
        viewController.finishAction = { [weak self, weak viewController] in
            
            /*
             */
            
            UIView.transition(
                with: rootViewController.view,
                duration: 0.4,
                options: [
                    .transitionFlipFromLeft
                ]
            ) {
                viewController?.removeFromParent()
                viewController?.view.removeFromSuperview()
            } completion: { _ in
                
            }
            
            self?.playerViewController = nil
        }
        
        /*
         */
        
        playerViewController = viewController
        
    }
    
    /*
     MARK: -
     */
    
    private func playVideo() {
        guard let url = url else { return }

        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(
            player: queuePlayer,
            templateItem: playerItem
        )
        
        playerLayer = AVPlayerLayer(player: queuePlayer)
        videoContainerView.layer.insertSublayer(playerLayer, at: 0)
        queuePlayer.play()
    }
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return dataProvider.count + 4
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(
            withReuseIdentifier: PackageCell.CellID,
            for: indexPath
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: GalleryHeaderView.HeaderID,
            for: indexPath
        )
        
        return headerView
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        guard indexPath.item < dataProvider.count else { return }
        
        let package = dataProvider[indexPath.item]
        if let cell = cell as? PackageCell {
            cell.package = package
            cell.selectAction = { [weak self] in
                self?.showPlayer(for: package)
            }
        }
    }
    
//    func collectionView(
//        _ collectionView: UICollectionView,
//        didSelectItemAt indexPath: IndexPath
//    ) {
//        guard indexPath.item < dataProvider.count else { return }
//
//        let package = dataProvider[indexPath.item]
//        showPlayer(for: package)
//    }
}
