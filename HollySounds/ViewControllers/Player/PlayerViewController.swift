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
    
    @IBOutlet weak var packNameLabel: UILabel!
  @IBOutlet var pageControl: UIPageControl!
    
  @IBOutlet weak var samplerLabel: UILabel!
  @IBOutlet weak var looperLabel: UILabel!
  
  private let shapeLayer: CALayer = {
    let shapeLayer = CALayer()
    shapeLayer.backgroundColor = UIColor.oomieWhite.cgColor
    shapeLayer.bounds = CGRect(x: 0, y: 0, width: 68, height: 1)
    return shapeLayer
  }()
  
  private let shapeView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .oomieWhite
    return view
  }()
  
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
      let contentOffset: CGPoint = CGPoint(x: state == .ambiences ? 0 : scrollView.bounds.width, y: 0)
      scrollView.setContentOffset(contentOffset, animated: true)
      pageControl.currentPage = state.rawValue
    }
  }
  
  var sessionTracker: SessionTracker!
  
  var tutorial: Tutorial = .firstScreen
  var tempViews: [UIView] = []
  var tutorialView = TutorialInfoView()
  private var handImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "Hand1")
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  var timer: Timer?
  var buttonLayer1: CALayer?
  var buttonLayer2: CALayer?
  var buttonLayer3: CALayer?

    
    /*
     MARK: -
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /*
         */
        samplerLabel.textColor = .oomieWhite
        addLineView(to: samplerLabel)
        pageControl.isHidden = true
        setupBackButton()
        setupAutoplayButton()
        setupRecordButton()
        
        /*
         */
        
        playVideo()
        
        /*
         */
      
      let sortedSounds = package.sounds.sorted(by: { $0.noteNumber > $1.noteNumber })
      sortedSounds.forEach { sound in
        
        if sound.type == .single {
            let touchPadView = TouchPadView.fromNib()
            touchPadView.translatesAutoresizingMaskIntoConstraints = false
            touchPadView.sound = sound
            soundContainer.addSubview(touchPadView)
          soundsPadViews.insert(touchPadView, at: 0)
        } else {
            let touchPadView = TouchPadView.fromNib()
            touchPadView.isFinishTutorial = sessionTracker.isPlayedBefore
          
          for tuts in Tutorial.allCases {
            if tuts.pad.hasPrefix(sound.soundFileName) {
              self.tempViews.append(touchPadView)
            }
          }
          
          if !sessionTracker.isPlayedBefore {
            if sound.soundFileName == tutorial.pad {
              touchPadView.isPlayable = true
              
              touchPadView.didTapPlay = { [weak self] in
                if self?.tutorial == .firstScreen {
                  touchPadView.isPlayable = false
                  touchPadView.stopTimer()
                  guard let secondView = self?.tempViews.last, let touchView = secondView as? TouchPadView else { return }
                  self?.addTutorialView(secondView.frame, tutorial: .secondScreen)
                  touchView.isPlayable = true
                  touchView.fireTimer()
                  touchView.didTapPlay = { [weak self] in
                    touchView.isPlayable = false
                    touchView.stopTimer()
                    if self?.tutorial == .secondScreen {
                      guard let btn = self?.autoPlayButton else { return }
                      self?.addTutorialView(btn.frame, tutorial: .thirdScreen)
                    }
                  }
                }
                
              }
            }
          } else {
            touchPadView.isPlayable = true
          }
          
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
      
      looperLabel.isUserInteractionEnabled = true
      let loopTap = UITapGestureRecognizer(target: self, action: #selector(didTapLooper))
      looperLabel.addGestureRecognizer(loopTap)
      
      samplerLabel.isUserInteractionEnabled = true
      let sampleTap = UITapGestureRecognizer(target: self, action: #selector(didTapSampler))
      samplerLabel.addGestureRecognizer(sampleTap)
      
        
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
      
      packNameLabel.text = package.title
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
        
      if sessionTracker.isPlayedBefore {
        SoundManager.shared.isAutoplayEnabled = true
      } else {
        guard let first = tempViews.first else { return }
        addTutorialView(first.frame, tutorial: .firstScreen)
      }
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
        autoPlayButton.didTouchAction = { [weak self] in
          if self?.sessionTracker.isPlayedBefore == true || self?.tutorial == .thirdScreen {
            SoundManager.shared.isAutoplayEnabled.toggle()
            if self?.tutorial == .thirdScreen {
              self?.sessionTracker.isPlayedBefore = true
              self?.handImageView.removeFromSuperview()
              self?.tutorialView.removeFromSuperview()
              self?.timer?.invalidate()
              self?.timer = nil
              self?.buttonLayer1?.removeFromSuperlayer()
              self?.buttonLayer1 = nil
              self?.buttonLayer2?.removeFromSuperlayer()
              self?.buttonLayer2 = nil
              self?.buttonLayer3?.removeFromSuperlayer()
              self?.buttonLayer3 = nil
              self?.sessionTracker.isPlayedBefore = true
            }
          }
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
    if sessionTracker.isPlayedBefore {
      state = .sounds
      changePageController(state: .sounds)
    }
  }
    
    @objc
    private func swipeRightAction(_ gesture: UISwipeGestureRecognizer) {
      if sessionTracker.isPlayedBefore {
        state = .ambiences
        changePageController(state: .ambiences)
      }
    }
  
  @objc private func didTapLooper() {
    if sessionTracker.isPlayedBefore {
      state = .sounds
      changePageController(state: .sounds)
    }
  }
  
  @objc private func didTapSampler() {
    if sessionTracker.isPlayedBefore {
      state = .ambiences
      changePageController(state: .ambiences)
    }
  }
  
  private func changePageController(state: PlayerState) {
    switch state {
    case .ambiences:
      samplerLabel.textColor = .oomieWhite
      looperLabel.textColor = .oomieWhite.withAlphaComponent(0.5)
      addLineView(to: samplerLabel)
    case .sounds:
      samplerLabel.textColor = .oomieWhite.withAlphaComponent(0.5)
      looperLabel.textColor = .oomieWhite
      addLineView(to: looperLabel)
    }
  }
    
    /*
     MARK: -
     */
    
    @objc
    private func willEnterForegroundAction(_ notification: Notification) {
        queuePlayer.play()
    }
  
  private func addLineView(to parentView: UIView) {
    shapeView.removeFromSuperview()
    
    
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
      parentView.addSubview(self.shapeView)
      self.shapeView.topAnchor.constraint(equalTo: parentView.bottomAnchor, constant: 3).isActive = true
      self.shapeView.widthAnchor.constraint(equalTo: parentView.widthAnchor, multiplier: 1).isActive = true
      self.shapeView.heightAnchor.constraint(equalToConstant: 1).isActive = true
      
      parentView.layoutIfNeeded()
    }
    
  }

  private func addLineLayer(_ sublayer: CALayer) {
    self.shapeLayer.removeFromSuperlayer()
    UIView.animate(withDuration: 0.4) {
      
      self.shapeLayer.position = CGPoint(x: sublayer.bounds.midX,
                                         y: sublayer.bounds.maxY + 3)
      
      
      
      sublayer.addSublayer(self.shapeLayer)
      self.looperLabel.layoutIfNeeded()
    }
  }
  
  private func addTutorialView(_ frame: CGRect, tutorial: Tutorial) {
    self.tutorial = tutorial
    tutorialView.alpha = 0
    handImageView.alpha = 0
    
    switch tutorial {
    case .firstScreen:
      view.addSubview(tutorialView)
      view.addSubview(handImageView)
      let point = CGPoint(x: frame.minX - tutorial.size.width , y: frame.midY + 8)
      tutorialView.frame = .init(origin: point, size: tutorial.size)
      let handPoint = CGPoint(x: frame.minX + 24, y: frame.midY + 8)
      handImageView.frame = .init(origin: handPoint, size: CGSize(width: 65, height: 65))
    case .secondScreen:
      let handPoint = CGPoint(x: frame.minX + 24, y: frame.midY)
      handImageView.frame = .init(origin: handPoint, size: CGSize(width: 65, height: 65))
      let point = CGPoint(x: frame.midX - 112 , y: frame.maxY + 32.5)
      tutorialView.frame = .init(origin: point, size: tutorial.size)
    case .thirdScreen:
      let handPoint = CGPoint(x: frame.minX + 6, y: frame.midY + 10)
      handImageView.frame = .init(origin: handPoint, size: CGSize(width: 65, height: 65))
      let point = CGPoint(x: frame.maxX - 340 , y: frame.maxY + 48)
      tutorialView.frame = .init(origin: point, size: tutorial.size)
      let buttonLayerPoint = CGPoint(x: autoPlayButton.bounds.midX + 2, y: autoPlayButton.bounds.midY)
      addlayersToButton(point: buttonLayerPoint)
      timer?.invalidate()
      timer = nil
      buttonLayer1?.opacity = 0
      buttonLayer2?.opacity = 0
      buttonLayer3?.opacity = 0
      
      timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(newTimer), userInfo: nil, repeats: true)
      timer?.fire()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
        self.tutorialView.alpha = 1
        self.handImageView.alpha = 1
        self.tutorialView.set(tutorial: tutorial)
        self.view.layoutIfNeeded()
        self.tutorialView.layoutIfNeeded()
        self.handImageView.layoutIfNeeded()
      }
    }
  }
  
  private func addlayersToButton(point: CGPoint) {
    var size: CGFloat = 0.0
    let image = UIImage(named: "traiangle")?.cgImage
    for i in 0...2 {
      if i == 0 {
        size = 26
        buttonLayer1 = CALayer()
        buttonLayer1?.opacity = 0.65
        buttonLayer1?.frame = CGRect(origin: point, size: CGSize(width: size, height: size))
        buttonLayer1?.position = point
        buttonLayer1?.contents = image
        autoPlayButton.layer.contentsGravity = .center
        autoPlayButton.layer.addSublayer(buttonLayer1 ?? CALayer())
      } else if i == 1 {
        size = 36
        buttonLayer2 = CALayer()
        buttonLayer2?.opacity = 0.35
        buttonLayer2?.frame = CGRect(origin: point, size: CGSize(width: size, height: size))
        buttonLayer2?.position = point
        buttonLayer2?.contents = image
        autoPlayButton.layer.contentsGravity = .center
        autoPlayButton.layer.addSublayer(buttonLayer2 ?? CALayer())
      } else if i == 2 {
        size = 46
        buttonLayer3 = CALayer()
        buttonLayer3?.opacity = 0.15
        buttonLayer3?.frame = CGRect(origin: point, size: CGSize(width: size, height: size))
        buttonLayer3?.position = point
        buttonLayer3?.contents = image
        autoPlayButton.layer.contentsGravity = .center
        autoPlayButton.layer.addSublayer(buttonLayer3 ?? CALayer())
      }
    }
  }
  
  @objc private func newTimer() {
    guard let layer3 = buttonLayer3 else { return }
    
    UIView.animate(withDuration: 0, delay: 0) {
      layer3.opacity = 0.15
      layer3.layoutIfNeeded()
      self.disable1(layer: layer3)
    }
  }
  
  private func disable1(layer: CALayer) {
    guard let layer2 = buttonLayer2 else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer.opacity = 0
        layer.layoutIfNeeded()
        layer2.opacity = 0.35
        layer2.layoutIfNeeded()
        self.disable2(layer: layer2)
      }
    }
  }
  
  private func disable2(layer: CALayer) {
    guard let layer1 = buttonLayer1 else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer.opacity = 0
        layer.layoutIfNeeded()
        layer1.opacity = 0.65
        layer1.layoutIfNeeded()
        self.disable3(layer: layer1)
      }
    }
  }
  
  private func disable3(layer: CALayer) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer.opacity = 0
        layer.layoutIfNeeded()
      }
    }
  }
  
  private func disableLayer(layer: CALayer) {
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer.opacity = 0
        layer.layoutIfNeeded()
      }
    }
  }
  
  @objc private func startTimer() {
    guard let layer1 = buttonLayer1, let layer2 = buttonLayer2, let layer3 = buttonLayer3 else { return }
    UIView.animate(withDuration: 0, delay: 0) {
      layer1.opacity = 0.65
      layer1.layoutIfNeeded()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer2.opacity = 0.35
        layer2.layoutIfNeeded()
      }
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer3.opacity = 0.15
        layer3.layoutIfNeeded()
        self.disables()
      }
    }
  }
  
  
  private func disables() {
    guard let layer1 = buttonLayer1, let layer2 = buttonLayer2, let layer3 = buttonLayer3 else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer3.opacity = 0
        layer3.layoutIfNeeded()
      }
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer2.opacity = 0
        layer2.layoutIfNeeded()
      }
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer1.opacity = 0
        layer1.layoutIfNeeded()
      }
    }
  }
  
  @objc private func startTimer2() {
    guard let layer1 = buttonLayer1, let layer2 = buttonLayer2, let layer3 = buttonLayer3 else { return }
   
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
      UIView.animate(withDuration: 0, delay: 0) {
        layer3.opacity = 0
        layer3.layoutIfNeeded()
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
        UIView.animate(withDuration: 0, delay: 0) {
          layer2.opacity = 0
          layer2.layoutIfNeeded()
        }
      }
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
        UIView.animate(withDuration: 0, delay: 0) {
          layer1.opacity = 0
          layer1.layoutIfNeeded()
        }
      }
    }
  }
  
  @objc private func animateLayer1() {
    print("1111-1")
    guard let layer1 = buttonLayer1 else { return }
    UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0) {
      if layer1.opacity != 0 {
        layer1.opacity = 0
      } else {
        layer1.opacity = 0.65
      }
    }
  }
  
  @objc private func animateLayer2() {
    print("1111-2")
    guard let layer2 = buttonLayer2 else { return }
    UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0) {
      if layer2.opacity != 0 {
        layer2.opacity = 0
      } else {
        layer2.opacity = 0.35
      }
    }
  }
  
  @objc private func animateLayer3() {
    print("1111-3")
    guard let layer3 = buttonLayer3 else { return }
    UIView.animate(withDuration: 0, delay: 0, usingSpringWithDamping: 0, initialSpringVelocity: 0) {
      if layer3.opacity != 0 {
        layer3.opacity = 0
      } else {
        layer3.opacity = 0.15
      }
    }
  }
  
  
  @objc private func animateBtn() {
    
    guard let layer1 = buttonLayer1, let layer2 = buttonLayer2, let layer3 = buttonLayer3 else { return }
    
    UIView.animate(withDuration: 0, delay: 0.3, options: .curveLinear) {
      if layer2.opacity == 0 && layer3.opacity == 0 && layer1.opacity == 0 {
        layer1.opacity = 0.65
        layer2.opacity = 0
        layer3.opacity = 0
      } else if layer2.opacity == 0 && layer1.opacity != 0 && layer3.opacity == 0 {
        layer1.opacity = 0
        layer2.opacity = 0.35
        layer3.opacity = 0
      } else if layer2.opacity != 0 && layer1.opacity == 0 && layer3.opacity == 0 {
        layer1.opacity = 0
        layer2.opacity = 0
        layer3.opacity = 0.15
      } else if layer2.opacity == 0 && layer1.opacity == 0 && layer3.opacity != 0 {
        layer1.opacity = 0.65
        layer2.opacity = 0
        layer3.opacity = 0
      }
      
      layer1.layoutIfNeeded()
      layer2.layoutIfNeeded()
      layer3.layoutIfNeeded()
      self.autoPlayButton.layoutIfNeeded()
    }
  }
}

enum Tutorial: CaseIterable {
  case firstScreen, secondScreen, thirdScreen
  
  var pad: String {
    switch self {
    case .firstScreen:
      return "1-1 PAD 4"
    case .secondScreen:
      return "3-1 PAD 1"
    case .thirdScreen:
      return ""
    }
  }
  
  var description: String {
    switch self {
    case .firstScreen:
      return "Start the 1st\n sound layer"
    case .secondScreen:
      return "Add the second"
    case .thirdScreen:
      return "Tap here to have Oomie\n pick the sound\n combinations by itself\n and non-stop"
    }
  }
  
  var size: CGSize {
    switch self {
    case .firstScreen:
      return .init(width: 185, height: 96)
    case .secondScreen:
      return .init(width: 224, height: 72)
    case .thirdScreen:
      return .init(width: 320, height: 168)
    }
  }
}
