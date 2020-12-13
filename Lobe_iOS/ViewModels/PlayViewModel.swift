//
//  PlayViewModel.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 12/1/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import SwiftUI
import Vision

enum PlayViewMode {
    case Camera
    case ImagePreview
}

/// View model for the Play View
class PlayViewModel: ObservableObject {
    @Published var classificationLabel: String?
    @Published var confidence: Float?
    @Published var viewMode: PlayViewMode = PlayViewMode.Camera
    @Published var image: UIImage?
    @Published var showImagePicker: Bool = false
    let project: Project
    private let imagePredicter: PredictionLayer
    private var disposables = Set<AnyCancellable>()
    
    init(project: Project) {
        self.project = project
        self.imagePredicter = PredictionLayer(model: project.model)
        
        // Subscribe to changes on image
        $image
            .drop(while: { $0 == nil })
            .sink(receiveValue: fetchPrediction(forImage:))
            .store(in: &disposables)
    }
    
    func fetchPrediction(forImage image: UIImage?) {
        guard let image = image else {
            print("Image not found")
            return
        }
        self.imagePredicter
            .getPrdiction(forImage: image, onComplete: { [weak self] request in
                DispatchQueue.main.async { [weak self] in
                    guard let classifications = request.results as? [VNClassificationObservation] else {
                        self?.classificationLabel = "Classification Error"
                        return
                    }
                    
                    if classifications.isEmpty {
                        self?.classificationLabel = "No Labels Found"
                    } else {
                        /* Display top classifications ranked by confidence in the UI. */
                        let topClassifications = classifications.prefix(1)
                        self?.classificationLabel = topClassifications[0].identifier
                        self?.confidence = topClassifications[0].confidence
                    }
                }
            }, onError: { [weak self] error in
                self?.classificationLabel = "Classification Error"
            })
    }
}
