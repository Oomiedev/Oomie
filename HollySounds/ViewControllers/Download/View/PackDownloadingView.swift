//
//  PackDownloadingView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 24.01.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct PackDownloadingView: View {
  
  @ObservedObject var viewModel: PackDownloadingViewModel
  @Environment(\.presentationMode) var presentationMode
  
    var body: some View {
      ZStack {
        backgroundView()
        VStack {
          Spacer()
          .frame(height: 65)
          HStack {
            Spacer()
            Button {
              withAnimation {
                viewModel.cancel()
                presentationMode.wrappedValue.dismiss()
              }
            } label: {
              Image("CloseIcon")
                .foregroundColor(.white)
            }

          }.padding(.horizontal, 16)
          
          Text(viewModel.package.title)
            .bold()
            .font(.title)
            .foregroundColor(.white)
          
          Spacer()
            .frame(height: 40)
          
          packIconView()
          
          Spacer()
            .frame(height: 64)
          
          Text("Downloading \(Int(viewModel.barLimit))%")
            .font(.body)
            .fontWeight(.regular)
            .foregroundColor(.white)
          
          HStack {
            ProgressBar(precent: $viewModel.barLimit)
              
          }.padding(.horizontal, 16)
          
          Spacer()
        }
      }
      .edgesIgnoringSafeArea(.all)
      .onAppear {
        viewModel.download()
      }
      .onDisappear {
        viewModel.remove?()
      }
    }
}

private extension PackDownloadingView {
  
  private func backgroundView() -> some View {
    backgroundImageView
      .blur(radius: 15)
      .foregroundColor(.black)
  }
  
  private func packIconView() -> some View {
    backgroundImageView
      .frame(width: 300, height: 300)
      .cornerRadius(12)
  }
  
  private var backgroundImageView: some View {
    Group {
      if let urlString = viewModel.package.serverImageURLString {
        AnimatedImage(url: URL(string: urlString))
          .resizable()
          .foregroundColor(.black)
      }
    }
  }
}


final class PackDownloadingViewModel: NSObject, ObservableObject, URLSessionDownloadDelegate {
  
  var package: Package!
  
  @Published var barLimit: CGFloat = 0
  
  var downloadTaskSession: URLSessionDownloadTask?
  
  var remove: (() -> Void)?
  
  func download() {
    guard let url = URL(string: "http://104.248.89.173:1337/uploads/Sea_Breeze_5bda00ae4e.zip") else { return }
    
    let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    downloadTaskSession = session.downloadTask(with: url)
    downloadTaskSession?.resume()
    session.finishTasksAndInvalidate()
  }
  
  func cancel() {
    downloadTaskSession?.cancel()
    downloadTaskSession = nil
  }
  
  func calculatePercentage(value: Double, percentageVal: Double)-> Double {
      let val = value * percentageVal
      return val / 100.0
  }
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    
    let progress = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
    print(progress)
    DispatchQueue.main.async {
      self.barLimit = progress
    }
  }
}

struct ProgressBar: View {
  @Binding var precent: CGFloat
  var body: some View {
    let size = UIScreen.main.bounds.width - 32
    let multiplier = size / 100
    ZStack(alignment: .leading) {
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .frame(maxWidth: .infinity)
        .frame(height: 4)
        .foregroundColor(.black.opacity(0.1))
      
      RoundedRectangle(cornerRadius: 12, style: .continuous)
        .frame(width: precent * multiplier)
        .frame(height: 4)
        .foregroundColor(.white)
    }
    .onAppear {
      
    }
  }
}
