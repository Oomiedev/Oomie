//
//  PackDownloadingView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 24.01.2023.
//

import SwiftUI
import SDWebImageSwiftUI

struct PackDownloadingView: View {
  
  @StateObject var viewModel: PackDownloadingViewModel
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
        
      }.edgesIgnoringSafeArea(.all)
        .onAppear {
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            viewModel.barLimit = 20
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
              viewModel.barLimit = 70
              
              
            }
          }
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

struct PackDownloadingView_Previews: PreviewProvider {
    static var previews: some View {
      PackDownloadingView(viewModel: PackDownloadingViewModel())
    }
}

final class PackDownloadingViewModel: ObservableObject {
  
  @Published var package: Package!
  
  @Published var barLimit: CGFloat = 5
  
  func calculatePercentage(value: Double, percentageVal: Double)-> Double {
      let val = value * percentageVal
      return val / 100.0
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
