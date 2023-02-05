//
//  PackageCell.swift
//  HollySounds
//
//  Created by Ne Spesha on 17.04.22.
//

import Foundation
import AFKit
import UIKit
import RealmSwift
import SDWebImage

final class PackageCell: AFDefaultCollectionViewCell {
    
    /*
     MARK: -
     */
    
    static let CellID: String = "PackageCell"
    
    /*
     MARK: -
     */
    
    @IBOutlet private var imageContainerView: UIView!
    @IBOutlet private var imageView: AFInteractiveImageView!
    @IBOutlet private var titleLabel: AFLabel!
    
    @IBOutlet private var playButton: AFInteractiveView!
    @IBOutlet private var playButtonImageView: UIImageView!
    @IBOutlet weak var lockIcon: UIImageView!
  
    var package: Package! {
        willSet {
            notificationToken?.invalidate()
        }
        didSet {
            notificationToken = package.observe(keyPaths: [\Package.isPreviewPlaying], on: .main, { [weak self] change in
                switch change {
                case .error(let error):
                    print(error)
                case .change(_, _):
                    self?.updateUI()
                case .deleted:
                    self?.notificationToken?.invalidate()
                }
            })
          
          notificationToken = package.observe(keyPaths: [\Package.status], on: .main, { [weak self] change in
            
            switch change {
            case .error(let error):
              print("Observing Package Error: ", error)
            case .change(_, _):
              self?.updateUI()
            case .deleted:
              self?.notificationToken?.invalidate()
            }
            
          })
            
            updateUI()
        }
    }
    var selectAction: Closure?
    
    /*
     MARK: -
     */
    
    private var notificationToken: NotificationToken?
    
    /*
     MARK: -
     */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /*
         */
        
        imageContainerView.layer.cornerRadius = 12 * SizeFactor
        
        imageView.didTouchAction = { [weak self] in
            self?.selectAction?()
        }
        
        /*
         */
        
        playButton.isHidden = true
        playButton.didTouchAction = { [weak self] in
            guard let self = self else { return }
            
            if self.package.isPreviewPlaying {
                SoundManager.shared.stopCurrentPreview()
            } else {
                SoundManager.shared.stopCurrentPreview()
                SoundManager.shared.playPreview(for: self.package)
            }
        }
    }
    
    private func updateUI() {
        
        /*
         */
        
        titleLabel.text = package.title
        
        /*
         */
        
        if
            let imageURLString = package.imageURLString,
            let url = URL(string: imageURLString),
            let data = try? Data(contentsOf: url)
        {
            imageView.image = UIImage(data: data)
        } else {
          if let serverImage = package.serverImageURLString {
            imageView.sd_imageProgress = .current()
            imageView.sd_setImage(with: URL(string: serverImage))
          }
        }
      
      print("1111-0 Name: \(package.title)/n Status: \(package.status)")
      
      switch package.status {
      case .live:
        lockIcon.image = nil
      case .pro:
        lockIcon.image = UIImage(named: "lock")
      case .downloaded:
        lockIcon.image = UIImage(named: "download")
      }
        
        /*
         */
        
        if let package = package {
            playButton.isHidden = false
            playButtonImageView.image = UIImage(named: package.isPreviewPlaying ? "PauseButton" : "PlayButton")
        } else {
            playButton.isHidden = true
        }
    }
}
