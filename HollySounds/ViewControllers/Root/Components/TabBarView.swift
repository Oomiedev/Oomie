//
//  TabBarView.swift
//  Dating
//
//  Created by Ne Spesha on 5.07.21.
//

import Foundation
import AFKit
import RealmSwift
import UIKit

public struct TabBarViewItem {
    var image: UIImage!
    var title: String!
    var notificationCount: Int!
}

final public class TabBarView: AFDefaultView {
    
    /*
     MARK: -
     */
    
    public var dataProvider: [TabBarViewItem] = [] {
        didSet {
            updateUI()
        }
    }
    public override var tintColor: UIColor! {
        didSet {
            updateUI()
        }
    }
    public var iconsColor: UIColor? = .gray {
        didSet {
            updateUI()
        }
    }
    
    /*
     MARK: -
     */
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private var notificationToken: NotificationToken!
    
    /*
     MARK: -
     */
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        /*
         */
        
        isAutomaticalyResizeEnabled = true
        
        /*
         */
        
        addSubview(stackView)
        stackView.bindToSuperview()
        
        /*
         */
        
        setupObserver()
    }
    
    /*
     MARK: -
     */
    
    private func setupObserver() {
        notificationToken = Settings.current
            .observe(
                keyPaths: ["currentSectionIndex"],
                { [weak self] changes in
                    switch changes {
                    case .change(_, _):
                        DispatchQueue.main.async {
                            self?.updateUI()
                        }
                    case .deleted:
                        self?.notificationToken?.invalidate()
                    case .error(let error):
                        print(error)
                    }
                }
            )
    }
    
    private func updateUI() {
        
        /*
         */
        
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        /*
         */
        
        var index = 0
        for item in dataProvider {
            
            /*
             */
            
            let interactiveView = TabBarInteractiveView()
            interactiveView.tag = index
            interactiveView.image = item.image
            interactiveView.title = item.title
            interactiveView.tintColor = Settings.current.currentSectionIndex == index ? tintColor : iconsColor
            interactiveView.notificationsCount = item.notificationCount
            interactiveView.didTouchAction = { [weak interactiveView] in
                guard let index = interactiveView?.tag else { return }
                
                /*
                 */
                
                guard Settings.current.currentSectionIndex != index else { return }
                
                try! Settings.current.realm?.safeWrite {
                    Settings.current.currentSectionIndex = index
                }
            }
            stackView.addArrangedSubview(interactiveView)
            
            /*
             */
            
            index += 1
        }
        
    }
    
}

/*
 MARK: -
 */

class TabBarInteractiveView: AFInteractiveView {
    
    /*
     MARK: -
     */
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    override var tintColor: UIColor? {
        didSet {
            imageView.tintColor = tintColor
            titleLabel.textColor = tintColor
        }
    }
    
    var notificationsCount: Int! {
        didSet {
            notificationView.isHidden = notificationsCount < 1
            countLabel.text = String(notificationsCount)
        }
    }
    
    /*
     MARK: -
     */
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 2 * SizeFactor
        return stackView
    }()
    private var countLabel: AFLabel = {
        let label = AFLabel()
        label.isAutomaticalyResizeEnabled = true
        label.font = UIFont.customFont(
            weight: .semibold,
            size: 10
        )
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    private var notificationView: AFRoundedView = {
        let view = AFRoundedView()
        view.isEnabled = false
        view.backgroundColor = UIColor(named: "Color 6")
        view.layer.borderWidth = 2 * SizeFactor
        view.layer.borderColor = UIColor(named: "Color 1")?.cgColor
        return view
    }()
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor
            .constraint(equalToConstant: 29 * SizeFactor)
            .isActive = true
        return imageView
    }()
    private var titleLabel: AFLabel = {
        let label = AFLabel()
        label.isAutomaticalyResizeEnabled = true
        label.font = UIFont.customFont(
            weight: .semibold,
            size: 10
        )
        label.textAlignment = .center
        return label
    }()
    
    /*
     MARK: -
     */
    
    override func awakeFromNib() {
        
        /*
         */
        
        addSubview(stackView)
        stackView.topAnchor
            .constraint(
                equalTo: topAnchor,
                constant: 4 * SizeFactor
            ).isActive = true
        stackView.leftAnchor
            .constraint(
                equalTo: leftAnchor,
                constant: 0
            ).isActive = true
        rightAnchor
            .constraint(
                equalTo: stackView.rightAnchor,
                constant: 0
            ).isActive = true
        
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        
        /*
         */
        
        addSubview(notificationView)
        notificationView.addSubview(countLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /*
         */
        
        notificationView.frame.size = CGSize(
            width: 18 * SizeFactor,
            height: 18 * SizeFactor
        )
        notificationView.center = CGPoint(
            x: frame.width / 2 + 9 * SizeFactor,
            y: frame.height / 2 - 7 * SizeFactor
        )
        
        /*
         */
        
        countLabel.frame.size = CGSize(
            width: 18 * SizeFactor,
            height: 18 * SizeFactor
        )
        countLabel.frame.origin = .zero
    }
}

