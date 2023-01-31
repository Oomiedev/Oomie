//
//  DownloadViewController.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 22.01.2023.
//

import UIKit

final class DownloadViewController: UIViewController {
  
  let rootView = DownloadView()
  
  let package: Package
  
  var downloadTaskSession: URLSessionDownloadTask?
  
  var update: (() -> Void)?
  
  init(package: Package) {
    self.package = package
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    rootView.set(package: package)
    rootView.closeButton.addTarget(self, action: #selector(didTapCloseBtn), for: .touchUpInside)
    download()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    downloadTaskSession?.cancel()
    downloadTaskSession = nil
  }
  
  @objc private func didTapCloseBtn() {
    dismiss(animated: true)
  }
  
  private func download() {
    guard let urlString = package.packDownloadURLString, let url = URL(string: urlString) else { return }
    
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    downloadTaskSession = session.downloadTask(with: url)
    downloadTaskSession?.resume()
    session.finishTasksAndInvalidate()
  }
  
  let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

extension DownloadViewController: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let url = downloadTask.originalRequest?.url else {
      return
    }
    
    guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
    
    if #available(iOS 16.0, *) {
      let destinationURL = path.appending(component: url.lastPathComponent)
      try? FileManager.default.removeItem(at: destinationURL)
      
      do {
        
        try FileManager.default.copyItem(at: location, to: destinationURL)
        getDestinationURL(sourceURL: destinationURL)
        DispatchQueue.main.async {
          self.rootView.progressLabel.text = "Archiving..."
        }
        
      } catch let error {
        print("Please try again later ", error.localizedDescription)
      }
      
    } else {
      let destinationURL = path.appendingPathComponent(url.lastPathComponent)
      try? FileManager.default.removeItem(at: destinationURL)
      
      do {
        
        try FileManager.default.copyItem(at: location, to: destinationURL)
        getDestinationURL(sourceURL: destinationURL)
        DispatchQueue.main.async {
          self.rootView.progressLabel.text = "Archiving..."
        }
        
      } catch let error {
        print("Please try again later ", error.localizedDescription)
      }
    }
    
  }
  
  func localFilePath(for url: URL) -> URL {
    return documentsPath.appendingPathComponent(url.lastPathComponent)
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
    let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
    DispatchQueue.main.async {
      self.rootView.progressLabel.text = "Downloading \(Int(progress * 100))%"
      self.rootView.progressView.progress = Float(progress)
    }
  }
  
  private func getDestinationURL(sourceURL: URL) {
    DispatchQueue.main.async {
      let soundpackService = SoundPackServiceImpl()
      soundpackService.setupSinglePackage(packKey: self.package.title) {[weak self] status, destinationURL in
        if status {
          self?.archive(sourceURL: sourceURL, destinationURL: destinationURL)
        }
       }
    }
  }
  
  private func archive(sourceURL: URL, destinationURL: URL) {
    let achriveService = ArchivingServiceImpl()
    let data = SoundData(package: package, sourceURL: sourceURL, destinationURL: destinationURL)
    achriveService.unzip(data: [data]) { [weak self] status in
      DispatchQueue.main.async {
        self?.rootView.progressLabel.text = "Decoding..."
        self?.decode(data: data)
      }
    }
  }
  
  private func decode(data: SoundData) {
    let decodeService = DecodingServiceImpl()
    decodeService.decodeLoops(packs: [data]) { [weak self] finish in
      print("1111-Complete ", finish)
      self?.dismiss(animated: true, completion: {[weak self] in
        self?.update?()
      })
    }
  }
}
