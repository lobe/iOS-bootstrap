//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import SwiftUI
import Vision

/// Backend logic for predicting classifiers for a given image.
class PredictionLayer: NSObject {
  @Published var classificationResult: [VNClassificationObservation]?
  var model: VNCoreMLModel?
  
  /// Used for debugging image output
  @Published var imageForPrediction: UIImage?
  
  init(model: VNCoreMLModel?) {
    self.model = model
  }
  
  /// Prediction handler which updates `classificationResult` publisher.
  func getPrediction(forImage image: UIImage) {
    let requestHandler = createPredictionRequestHandler(forImage: image)
    
    /// Add image to publisher if enviornment variable is enabled.
    /// Used for debugging purposes.
    if Bool(ProcessInfo.processInfo.environment["SHOW_FORMATTED_IMAGE"] ?? "false") ?? false {
      self.imageForPrediction = image
    }
    
    /// Create request handler.
    let request = createModelRequest(
      /// Set classification result to publisher
      onComplete: { [weak self] request in
        guard let classifications = request.results as? [VNClassificationObservation],
              !classifications.isEmpty else {
          self?.classificationResult = nil
          return
        }

        // TODO: Move this to 3 and make sure the FOREACH is working.
        let topClassifications = classifications.prefix(3)
        self?.classificationResult = Array(topClassifications)
      }, onError: { [weak self] error in
        print("Error getting predictions: \(error)")
        self?.classificationResult = nil
      })
    
    try? requestHandler.perform([request])
  }
  
  /// Creates request handler and formats image for prediciton processing.
  private func createPredictionRequestHandler(forImage image: UIImage) -> VNImageRequestHandler {
    /* Crop to square images and send to the model. */
    guard let cgImage = image.cgImage else {
      fatalError("Could not create cgImage in captureOutput")
    }
    
    let ciImage = CIImage(cgImage: cgImage)
    let requestHandler = VNImageRequestHandler(ciImage: ciImage)
    return requestHandler
  }
  
  private func createModelRequest(onComplete: @escaping (VNRequest) -> (), onError: @escaping (Error) -> ()) -> VNCoreMLRequest {
    guard let model = model else {
      fatalError("Model not found in prediction layer")
    }
    
    let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
      if let error = error {
        onError(error)
      }
      onComplete(request)
    })
    
    /// Set center cropping for the expected image size.
    /// NOTE: Although center cropping is currently expected with Lobe's model version,
    /// please be mindful of future changes which may affect the expected preprocessing steps.
    request.imageCropAndScaleOption = .centerCrop
    return request
  }    
}
