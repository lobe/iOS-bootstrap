//
//  PredictionLayer.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/30/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import Foundation
import SwiftUI
import Vision

protocol ImageClassificationPredicter {
    func getPrdiction(forImage image: UIImage,
                      onComplete: @escaping (VNRequest) -> (),
                      onError: @escaping (Error) -> ())
}

/// Backend logic for predicting classifiers for a given image.
class PredictionLayer: NSObject, ImageClassificationPredicter {
    var model: VNCoreMLModel?
    
    init(model: VNCoreMLModel?) {
        self.model = model
    }
    
    func getPrdiction(forImage image: UIImage, onComplete: @escaping (VNRequest) -> (), onError: @escaping (Error) -> ()) {
        let requestHandler = createPredictionRequestHandler(forImage: image)
        let request = createModelRequest(onComplete: onComplete, onError: onError)
        
        try? requestHandler.perform([request])
    }

    func createPredictionRequestHandler(forImage image: UIImage) -> VNImageRequestHandler {
        /* Crop to square images and send to the model. */
        let _cgImage = image.squared()?.cgImage
        guard let cgImage = _cgImage else {
            fatalError("Could not create cgImage in captureOutput")
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        let requestHandler = VNImageRequestHandler(ciImage: ciImage)
        return requestHandler
    }
    
    func createModelRequest(onComplete: @escaping (VNRequest) -> (), onError: @escaping (Error) -> ()) -> VNCoreMLRequest {
        guard let model = model else {
            fatalError("Model not found in prediction layer")
        }

        let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            if let error = error {
                onError(error)
            }
            onComplete(request)
        })
        return request
    }    
}
