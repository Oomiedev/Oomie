//
//  NetworkingService.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 18.01.2023.
//

import Foundation

protocol NetworkingService: AnyObject {
    func fetchServerPacks(url: URL, completion: @escaping (Result<ServerPack, Error>) -> Void)
    func downloadOGG(urlString: String?, completion: @escaping (Result<URL, Error>) -> Void)
}

protocol NetworkingServiceOutput: AnyObject {
    func getSource(url: URL)
}

final class NetworkingServiceImpl {
  
    var downloadTaskSession: URLSessionDownloadTask?
}

extension NetworkingServiceImpl: NetworkingService {
  func fetchServerPacks(url: URL, completion: @escaping (Result<ServerPack, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      if let error = error {
        completion(.failure(error))
        return
      }
      
      guard let data = data else { return }
      
      do {
        let jsonData = try JSONDecoder().decode(ServerPack.self, from: data)
        completion(.success(jsonData))
      } catch let error {
        print("1111-0 Err ", error)
        completion(.failure(error))
      }
    }
    task.resume()
  }
    
  func downloadOGG(urlString: String?, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let urlString, let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Broken URL", code: 0)))
            return
        }
      
      
    }
}

struct ServerPack: Decodable {
  let data: [ModelData]
}

struct ModelData: Decodable {
  let attributes: Attributes
}

struct Attributes: Decodable {
  let title: String
  let content: Content
  let image: Content
  let previewSound: PreviewContent?
}

struct Content: Decodable {
  let data: ContentData
}

struct ContentData: Decodable {
  let attributes: ContentAttributes
}

struct ContentAttributes: Decodable {
  let size: Double
  let url: String
}

struct PreviewContent: Decodable {
    let data: PreviewContentData?
}

struct PreviewContentData: Decodable {
    let attributes: PreviewContentAttributes?
}

struct PreviewContentAttributes: Decodable {
    let url: String?
}
