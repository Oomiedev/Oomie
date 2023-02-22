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
import SwiftUI

final class GalleryViewController: AFDefaultViewController {

    /*
     MARK: -
     */
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private var videoContainerView: UIView!
  
  private lazy var loaderView: UIActivityIndicatorView = {
    let loader = UIActivityIndicatorView()
    loader.translatesAutoresizingMaskIntoConstraints = false
    loader.style = .large
    loader.color = .systemOrange
    return loader
  }()
    
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
  
  var viewModel: GalleryViewModel!
  private var selectedProPackIndex: IndexPath?
  private var currentPlayingIndex: IndexPath?
  
  var sessionTracker: SessionTracker!
  
  /*
   MARK: -
   */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDataProvider()
        setupCollectionView()
        playVideo()
      
      viewModel.updateUI = { [weak self] prossess in
        if prossess {
          self?.startLoading()
        } else {
          self?.loaderView.removeFromSuperview()
        }
      }
      
      viewModel.updateUIWithFetchedPackage = { [weak self] in
        self?.collectionView.reloadData()
      }
      
      viewModel.updateSubscription = { [weak self] in
        self?.collectionView.reloadData()
      }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let value = playerLayer {
            value.frame = videoContainerView.bounds
        }
    }
  
  private func startLoading() {
    view.addSubview(loaderView)
    
    NSLayoutConstraint.activate([
      loaderView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      loaderView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      loaderView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      loaderView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    
    loaderView.startAnimating()
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
        
      let item = NSCollectionLayoutItem( layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .estimated(100)))
        
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
      do {
        let realm = try Realm()
        dataProvider = realm.objects(Package.self)
      } catch let error {
        print("1111-0 Err: ", error)
      }
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
        viewController.sessionTracker = sessionTracker
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
  
  private func showSubsctiption() {
    appDelegate.checkSubscription()
  }
  
  private func showDownload(for package: Package) {
    let vc = DownloadViewController(package: package)
    
    vc.push = { [weak self] in
      self?.showPlayer(for: package)
    }
    
    vc.update = { [weak self] in
      guard let index = self?.selectedProPackIndex else { return }
      self?.collectionView.reloadItems(at: [index])
    }
    
    vc.modalPresentationStyle = .overCurrentContext
    present(vc, animated: true)
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
        return dataProvider.count
    }
    
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PackageCell.CellID, for: indexPath) as? PackageCell else { fatalError() }
    
    cell.setIndex(index: indexPath)
    
    cell.previewCell = { [weak self] index in
      self?.resetPreview()
      self?.currentPlayingIndex = index
    }
    
    return cell
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
              switch cell.package.status {
              case .live:
                self?.resetPreview()
                self?.showPlayer(for: package)
              case .pro:
                self?.showSubsctiption()
              case .downloaded:
                self?.showDownload(for: package)
                self?.selectedProPackIndex = indexPath
              }
            }
        }
    }
  
  private func resetPreview() {
    if let oldCellIndex = currentPlayingIndex {
      if let oldCell = collectionView.cellForItem(at: oldCellIndex) as? PackageCell {
        oldCell.resetPreview()
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

extension UIViewController {
    var appDelegate: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
   }
}
