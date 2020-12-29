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
}

/// View model for the Play View
class PlayViewModel: ObservableObject {
    @Published var classificationLabel: String?
    @Published var confidence: Float?
    @Published var viewMode: PlayViewMode = PlayViewMode.Camera
    @Published var showImagePicker: Bool = false
    let project: Project
    let imagePredicter: PredictionLayer
    private var disposables = Set<AnyCancellable>()
    
    init(project: Project) {
        self.project = project
        self.imagePredicter = PredictionLayer(model: project.model)
        
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
    }
}
