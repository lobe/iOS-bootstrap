//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import SwiftUI

enum PlayViewMode {
  case Camera
  case ImagePreview
  case NotLoaded
}

/// View model for the Play View
class PlayViewModel: ObservableObject {
  @Published var classificationLabels: [String]?
  @Published var confidences: [Float]?
  @Published var viewMode: PlayViewMode = PlayViewMode.NotLoaded
  @Published var showImagePicker: Bool = false
  @Published var imageFromPhotoPicker: UIImage?
  var captureSessionManager: CaptureSessionManager
  let project: Project
  var imagePredicter: PredictionLayer
  private var disposables = Set<AnyCancellable>()
  
  init(project: Project) {
    self.project = project
    self.imagePredicter = PredictionLayer(model: project.model)
    self.captureSessionManager = CaptureSessionManager()
    /// Subscribes to two publishers:
    ///     1. `capturedImageOutput` published from `Camera` mode.
    ///     2.  `imageFromPhotoPicker` published from `ImagePreview` mode.
    /// If either of the above publishers emit, we send it's output to the prediction layer for classification results.
    self.self.$imageFromPhotoPicker
      .merge(with: captureSessionManager.$capturedImageOutput)
      .compactMap { $0 }  // remove non-nill values
      .receive(on: DispatchQueue.global(qos: .userInitiated))
      .sink(receiveValue: { [weak self] image in
        guard let squaredImage = image.squared() else {
          print("Could not create squared image in PlayViewModel.")
          return
        }
        self?.imagePredicter.getPrediction(forImage: squaredImage)
      })
      .store(in: &disposables)
    
    /// Subscribe to classifier results from prediction layer
    self.imagePredicter.$classificationResult
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: {[weak self] classificationResult in
        guard let _classificationResult = classificationResult else {
          self?.classificationLabels = ["Loading..."]
          return
        }

        self?.classificationLabels = _classificationResult.map { $0.identifier }
        self?.confidences = _classificationResult.map { $0.confidence }
      })
      .store(in: &disposables)
    
    /// Update camera session if toggled between view mode.
    self.$viewMode
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] _viewMode in
        if _viewMode == .Camera { self?.captureSessionManager.resetCameraFeed() }
        else { self?.captureSessionManager.tearDown() }
      })
      .store(in: &disposables)
  }
}
