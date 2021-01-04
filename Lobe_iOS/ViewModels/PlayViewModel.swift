//
//  PlayViewModel.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 12/1/20.
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
    @Published var classificationLabel: String?
    @Published var confidence: Float?
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
        self.captureSessionManager = CaptureSessionManager(predictionLayer: self.imagePredicter)
        
        /// Subscribes to two publishers:
        ///     1. `capturedImageOutput` published from `Camera` mode.
        ///     2.  `imageFromPhotoPicker` published from `ImagePreview` mode.
        /// If either of the above publishers emit, we send it's output to the prediction layer for classification results.
        self.$imageFromPhotoPicker
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
                    self?.classificationLabel = "Loading Results..."
                    return
                }
                self?.classificationLabel = _classificationResult.identifier
                self?.confidence = _classificationResult.confidence
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
