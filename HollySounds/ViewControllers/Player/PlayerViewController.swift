//
//  PlayerViewController.swift
//  HolllySounds
//
//  Created by Ne Spesha on 30.03.22.
//

import UIKit
import AFKit
import AVFoundation

fileprivate enum PlayerState: Int {
    case ambiences, sounds
}

final class PlayerViewController: AFDefaultViewController {
    
    deinit {
        SoundManager.shared.removeObserver(
            self,
            forKeyPath: #keyPath(SoundManager.isAutoplayEnabled)
        )
    }
    
    /*
     MARK: -
     */
    
    @IBOutlet var backButton: AFInteractiveView!
    
    @IBOutlet var autoPlayButton: AFInteractiveView!
    @IBOutlet var autoPlayButtonImageView: UIImageView!
    
    @IBOutlet var recordButton: AFInteractiveView!
    @IBOutlet var recordButtonImageView: UIImageView!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var soundContainer: UIView!
    @IBOutlet var ambientsContainer: UIView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    /*
     MARK: -
     */
    
    var finishAction: Closure?
    var package: Package!
    
    /*
     MARK: -
     */
    
    private let url = Bundle.main.url(forResource: "Video", withExtension: "mp4")
    
    private var playerLayer: AVPlayerLayer!
    
    private var playerLooper: AVPlayerLooper!
    private var queuePlayer: AVQueuePlayer!
    
    private var soundsPadViews: [TouchPadView] = []
    private var ambientsPadViews: [TouchPadView] = []
    
    private var state: PlayerState = .ambiences {
        didSet {
            
            /*
             */
            
            let contentOffset: CGPoint = CGPoint(
                x: state == .ambiences ? 0 : scrollView.bounds.width,
                y: 0
            )
            scrollView.setContentOffset(
                contentOffset,
                animated: true
            )
            
            /*
             */
            
            pageControl.currentPage = state.rawValue
        }
    }
    
    /*
     MARK: -
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         */
        
        setupBackButton()
        setupAutoplayButton()
        setupRecordButton()
        
        /*
         */
        
        playVideo()
        
        /*
         */
        
        package.sounds.forEach { sound in
            
            /*
             */
            
            if sound.type == .single {
                let touchPadView = TouchPadView.fromNib()
                touchPadView.translatesAutoresizingMaskIntoConstraints = false
                touchPadView.sound = sound
                soundContainer.addSubview(touchPadView)
                soundsPadViews.append(touchPadView)
            } else {
                let touchPadView = TouchPadView.fromNib()
                touchPadView.translatesAutoresizingMaskIntoConstraints = false
                touchPadView.sound = sound
                ambientsContainer.addSubview(touchPadView)
                ambientsPadViews.append(touchPadView)
            }
        }
        
        /*
         */
        
        SoundManager.shared.startEngine(for: package)
        
        /*
         */

        let swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeLeftAction))
        swipeLeftGesture.direction = .left
        view.addGestureRecognizer(swipeLeftGesture)
        
        /*
         */

        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeRightAction))
        swipeRightGesture.direction = .right
        view.addGestureRecognizer(swipeRightGesture)
        
        /*
         */
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForegroundAction(_:)),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        
        /*
         */
        
        SoundManager.shared.addObserver(
            self,
            forKeyPath: #keyPath(SoundManager.isAutoplayEnabled),
            context: nil
        )
    }
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(SoundManager.isAutoplayEnabled) {
            
            /*
             */
            
            autoPlayButtonImageView.layer.add(CATransition(), forKey: nil)
            autoPlayButtonImageView.image = UIImage(named: SoundManager.shared.isAutoplayEnabled ? "PauseIcon" : "PlayIcon")
            
            /*
             */
            
            state = .ambiences
        } else if keyPath == #keyPath(SoundManager.isRecordingEnabled) {
            
            /*
             */
            
            recordButtonImageView.layer.add(CATransition(), forKey: nil)
            recordButtonImageView.image = UIImage(named: SoundManager.shared.isRecordingEnabled ? "RecordButtonEnabled" : "RecordButton")
            
            /*
             */
            
            if SoundManager.shared.isRecordingEnabled {
                UIView.animate(withDuration: 0.3, delay: 0, options: [.autoreverse, .repeat]) {
                    self.recordButtonImageView.alpha = 0
                } completion: { _ in
                    
                }
            } else {
                recordButtonImageView.alpha = 1
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SoundManager.shared.isAutoplayEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /*
         */
        
        playerLayer.frame = view.bounds
        playerLayer.transform = CATransform3DScale(
            playerLayer.transform,
            1.5,
            1.5,
            1
        )
        
        
        /*
         */
        
         var positionsMap: [CGPoint] = [
            CGPoint(
                x: OffsetX,
                y: -OffsetY * 0.5
            ),
            CGPoint(
                x: -OffsetX * 2,
                y: 0
            ),
            CGPoint(
                x: OffsetX,
                y: -OffsetY * 0.5
            )
        ]
        var position = CGPoint(
            x: 0,
            y: OffsetY * 1.5
        )
        soundsPadViews.enumerated().forEach { [weak self] index, touchPadView in
            guard let self = self else { return }
            
            /*
             */
            
            touchPadView.removeConstraints(touchPadView.constraints)
            
            /*
             */
            
            let topConstraint = touchPadView.topAnchor
                .constraint(
                    equalTo: self.soundContainer.topAnchor,
                    constant: self.view.bounds.midY + position.y - TouchPadViewSize.width / 2
                )
            let leadingConstraint = touchPadView.leadingAnchor
                .constraint(
                    equalTo: self.soundContainer.leadingAnchor,
                    constant: self.view.bounds.midX + position.x - TouchPadViewSize.height / 2
                )
            
            let widthConstraint = touchPadView.widthAnchor
                .constraint(equalToConstant: TouchPadViewSize.width)
            let heightConstraint = touchPadView.heightAnchor
                .constraint(equalToConstant: TouchPadViewSize.height)
            
            topConstraint.isActive = true
            leadingConstraint.isActive = true
            widthConstraint.isActive = true
            heightConstraint.isActive = true
            
            /*
             */
            
            let offset = positionsMap[index % positionsMap.count]
            position.x += offset.x
            position.y += offset.y
        }
        
        /*
         */
        
        positionsMap = [
           CGPoint(
                x: -OffsetX,
                y: -OffsetY * 0.5
           ),
           CGPoint(
                x: OffsetX,
                y: -OffsetX * 0.5
           ),
           CGPoint(
                x: OffsetX,
                y: OffsetY * 0.5
           ),
           CGPoint(
                x: 0,
                y: OffsetY * 1.2
           ),
           CGPoint(
                x: -OffsetX,
                y: OffsetY * 0.5
           ),
           CGPoint(
                x: -OffsetX,
                y: -OffsetY * 0.5
           ),
           CGPoint(
                x: 0,
                y: -OffsetY * 2.4
           ),
           CGPoint(
                x: OffsetX,
                y: -OffsetY * 0.5
           ),
           CGPoint(
                x: OffsetX,
                y: OffsetY * 0.5
           )
       ]
        
        position = CGPoint(
            x: 0,
            y: OffsetY * 0.5
        )
        
        ambientsPadViews.enumerated().forEach { [weak self] index, touchPadView in
            guard let self = self else { return }
            
            /*
             */
            
            touchPadView.removeConstraints(touchPadView.constraints)
            
            /*
             */
            
            let topConstraint = touchPadView.topAnchor
                .constraint(
                    equalTo: self.ambientsContainer.topAnchor,
                    constant: self.view.bounds.midY + position.y - TouchPadViewSize.width / 2
                )
            let leadingConstraint = touchPadView.leadingAnchor
                .constraint(
                    equalTo: self.ambientsContainer.leadingAnchor,
                    constant: self.view.bounds.midX + position.x - TouchPadViewSize.height / 2
                )
            
            let widthConstraint = touchPadView.widthAnchor
                .constraint(equalToConstant: TouchPadViewSize.width)
            let heightConstraint = touchPadView.heightAnchor
                .constraint(equalToConstant: TouchPadViewSize.height)
            
            topConstraint.isActive = true
            leadingConstraint.isActive = true
            widthConstraint.isActive = true
            heightConstraint.isActive = true
            
            /*
             */
            
            let offset = positionsMap[index % positionsMap.count]
            position.x += offset.x
            position.y += offset.y
        }
    }
    
    private func playVideo() {
        
        /*
         */
        
        var url: URL?
        if let value = package.videoURLString {
            url = URL(string: value)
        }
        if FileManager.default.fileExists(atPath: url?.path ?? "") == false {
            url = self.url
        }

        guard let url = url else { return }

        /*
         */
        
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        queuePlayer = AVQueuePlayer(playerItem: playerItem)
        playerLooper = AVPlayerLooper(
            player: queuePlayer,
            templateItem: playerItem
        )
        
        playerLayer = AVPlayerLayer(player: queuePlayer)
        view.layer.insertSublayer(playerLayer, at: 0)
        queuePlayer.play()
    }
    
    func resolutionSizeForLocalVideo(url: URL) -> CGSize? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    
    /*
     MARK: -
     */
    
    private func setupBackButton() {
        backButton.didTouchAction = { [weak self] in
            
            /*
             */
        
            SoundManager.shared.clear()
            
            /*
             */
            
            self?.finishAction?()
        }
    }
    
    private func setupAutoplayButton() {
        autoPlayButton.didTouchAction = {
            SoundManager.shared.isAutoplayEnabled.toggle()
        }
    }
    
    private func setupRecordButton() {
        recordButton.didTouchAction = {
            SoundManager.shared.isRecordingEnabled.toggle()
        }
    }
    
    /*
     MARK: -
     */
    
    @objc
    private func swipeLeftAction(_ gesture: UISwipeGestureRecognizer) {
        state = .sounds
    }
    
    @objc
    private func swipeRightAction(_ gesture: UISwipeGestureRecognizer) {
        state = .ambiences
    }
    
    /*
     MARK: -
     */
    
    @objc
    private func willEnterForegroundAction(_ notification: Notification) {
        queuePlayer.play()
    }

}
