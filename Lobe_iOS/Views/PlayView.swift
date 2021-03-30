//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import SwiftUI

struct PlayView: View {
  
  @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
  @ObservedObject var viewModel: PlayViewModel
  
  init(viewModel: PlayViewModel) {
    self.viewModel = viewModel
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack {
        switch(self.viewModel.viewMode) {
        // Background camera view.
        case .Camera:
          ZStack {
            CameraView(captureSessionManager: self.viewModel.captureSessionManager)
              // Gesture for swiping up the photo library.
              .gesture(
                DragGesture()
                  .onEnded {value in
                    if value.translation.height < 0 {
                      withAnimation{
                        self.viewModel.showImagePicker.toggle()
                      }
                    }
                  }
              )
          }
        // Placeholder for displaying an image from the photo library.
        case .ImagePreview:
          ImagePreview(image: self.$viewModel.imageFromPhotoPicker, viewMode: self.$viewModel.viewMode)
          
        // TO-DO: loading screen here
        case .NotLoaded:
          Text("View Loading...")
        }
      }
      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
      .background(Color(UIColor(rgb: 0x333333)))
      .edgesIgnoringSafeArea(.all)

      /// Show processed image that gets used for prediction.
      VStack {
        if Bool(ProcessInfo.processInfo.environment["SHOW_FORMATTED_IMAGE"] ?? "false") ?? false {
          if let imageForProcessing = self.viewModel.imagePredicter.imageForPrediction {
            Image(uiImage: imageForProcessing)
              .resizable()
              .scaledToFit()
              .frame(width: 300, height: 300)
              .border(Color.blue, width: 8)
          }
        }
          if self.viewModel.showPredictionView {
            PredictionsView(predictions: self.viewModel.predictions)
              .transition(.move(edge: .bottom))
          }
      }
      .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .bottom)
      .edgesIgnoringSafeArea(.all)
      
      HStack(spacing: UIScreen.main.bounds.width - 80 - 44) {
        /// Photo picker button if in camera mode, else we show button to toggle to camera mode
        openPhotoPickerButton
        
        if (self.viewModel.viewMode == .Camera) {
          rotateCameraButton
        } else {
          showCameraModeButton
        }
      }
      .buttonStyle(PlayViewButtonStyle())
      .frame(width: UIScreen.main.bounds.width)
      .padding(EdgeInsets(top: 22, leading: 0, bottom: 0, trailing: 0))
      .edgesIgnoringSafeArea(.all)
    }
    .statusBar(hidden: true)
    .navigationBarBackButtonHidden(true)
    .navigationBarHidden(true)
    .sheet(isPresented: self.$viewModel.showImagePicker) {
      ImagePicker(image: self.$viewModel.imageFromPhotoPicker,
                  viewMode: self.$viewModel.viewMode,
                  predictionLayer: self.viewModel.imagePredicter,
                  sourceType: .photoLibrary)
        .edgesIgnoringSafeArea(.all)
    }
    .onAppear {
      self.viewModel.viewMode = .Camera
    }
    .onDisappear {
      /// Disable capture session
      self.viewModel.viewMode = .NotLoaded
    }
  }
}

extension View {
  func Print(_ vars: Any...) -> some View {
    for v in vars { print(v) }
    return EmptyView()
  }
}

extension Collection {
  /// Returns the element at the specified index if it is within bounds, otherwise nil.
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
}

extension PlayView {
  
  static let blurEffect = VisualEffectView(effect: UIBlurEffect(style: .dark))
  
  /// Button style for navigation row
  struct PlayViewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
      configuration.label
        .foregroundColor(.white)
        .frame(width: 40, height: 40, alignment: .center)
        .background(PlayView.blurEffect)
        .cornerRadius(20)
    }
  }
  
  /// Button for opening photo picker
  var openPhotoPickerButton: some View {
    Button(action: {
      self.viewModel.showImagePicker.toggle()
    }) {
      Image("gallery")
    }
  }
  
  /// Button for enabling camera mode
  var showCameraModeButton: some View {
    Button(action: {
      self.viewModel.viewMode = .Camera
    }) {
      Image("close")
    }
  }
  
  /// Button for rotating camera
  var rotateCameraButton: some View {
    Button(action: { self.viewModel.captureSessionManager.rotateCamera() }) {
      Image("rotate")
    }
  }
}

/// Gadget to build colors from Hashtag Color Code Hex.
extension UIColor {
  convenience init(red: Int, green: Int, blue: Int) {
    assert(red >= 0 && red <= 255, "Invalid red component")
    assert(green >= 0 && green <= 255, "Invalid green component")
    assert(blue >= 0 && blue <= 255, "Invalid blue component")
    
    self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
  }
  
  convenience init(rgb: Int) {
    self.init(
      red: (rgb >> 16) & 0xFF,
      green: (rgb >> 8) & 0xFF,
      blue: rgb & 0xFF
    )
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners) )
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}

struct PlayView_Previews: PreviewProvider {
  struct TestImage: View {
    var body: some View {
      Image("testing_image")
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
  }
  
  static var previews: some View {
    let viewModel1 = PlayViewModel(project: Project(mlModel: nil))
    let viewModel2 = PlayViewModel(project: Project(mlModel: nil))
    let viewModel3 = PlayViewModel(project: Project(mlModel: nil))
    let predictionFirst = Prediction(label: "Primary Prediction", confidence: 0.6)
    let predictionSecond = Prediction(label: "Second", confidence: 0.2)
    let predictionThird = Prediction(label: "Third", confidence: 0.1)
    viewModel1.predictions = [predictionFirst, predictionSecond, predictionThird]
    viewModel2.predictions = [predictionFirst, predictionSecond]
    viewModel3.predictions = []
    
    return Group {
      PlayView(viewModel: viewModel1)
        .previewDevice("iPhone 12")
      PlayView(viewModel: viewModel2)
        .previewDevice("iPhone 12")
      PlayView(viewModel: viewModel3)
        .previewDevice("iPhone 12")
    }
  }
}
