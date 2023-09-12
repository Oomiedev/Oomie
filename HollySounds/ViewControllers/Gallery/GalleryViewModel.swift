//
//  GalleryViewModel.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 13.01.2023.
//

import Foundation

final class GalleryViewModel: NSObject {
  
  private var proccessToken: NSKeyValueObservation?
  
  var updateUI: ((Bool) -> Void)?
  var updateUIWithFetchedPackage: (() -> Void)?
  var updateSubscription: (() -> Void)?
    
    var downloadTaskSession: URLSessionDownloadTask?
  
  func observe(job: Job) {
    proccessToken = job.observe(\.loadingProccess, options: [.new], changeHandler: { [weak self] job, change in
      guard let jobProssess = change.newValue else { return }
      self?.updateUI?(jobProssess)
    })
    
    proccessToken = job.observe(\.fetchingProcess, options: [.new], changeHandler: { [weak self] job, change in
      guard let _ = change.newValue else { return }
      self?.updateUIWithFetchedPackage?()
    })
  }
    
    func downloadPreview(with urls: [URL]) {
        for (_,j) in urls.enumerated() {
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
            downloadTaskSession = session.downloadTask(with: j)
            downloadTaskSession?.resume()
            session.finishTasksAndInvalidate()
        }
    }
}

extension GalleryViewModel: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url else {
          return
        }
        
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        var destinationURL: URL?
        
        let link = url.lastPathComponent
        var splitted = link.split(separator: "_")
        splitted.removeLast()
        
        
        let key = splitted.joined(separator: " ")
        
        if #available(iOS 16.0, *) {
            destinationURL = path.appending(component: url.lastPathComponent)
        } else {
            destinationURL = path.appendingPathComponent(url.lastPathComponent)
        }
        
        guard let destinationURL else { return }
        
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
            DispatchQueue.main.async {
                let soundpackService = SoundPackServiceImpl()
                soundpackService.setupSinglePackage(packKey: String(key)) { status, url in
                    self.archive(sourceURL: destinationURL, destinationURL: url, key: String(key))
                }
            }
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func archive(sourceURL: URL, destinationURL: URL, key: String) {
      let achriveService = ArchivingServiceImpl()
        achriveService.unzipPreview(destinationURL: destinationURL, sourceURL: sourceURL, key: key) { _ in }
    }
}

final class Job: NSObject {
  @objc dynamic var loadingProccess: Bool = false
  @objc dynamic var fetchingProcess: Bool = false
}
