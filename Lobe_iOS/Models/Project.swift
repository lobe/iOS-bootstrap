//
//  Project.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 10/11/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import Vision

/// Project class.
struct Project {
    var name: String
    var model: VNCoreMLModel?
}

/// Extension provides support for converting model from file URL. Using this pattern allows for an 'optional' `init`.
extension Project {
    /// Initialize Project instance with URL for stored model.
    init(name: String, modelFileURL: URL) {
        self.name = name
        self.model = convertFileToCoreML(atFileURL: modelFileURL)
    }
    
    /// Initialize Project instance with MLModel.
    init(name: String, model: MLModel) {
        self.name = name
        self.model = try? VNCoreMLModel(for: model)
    }
    
    /// Returns `VNCoreMLModel` instance from stored file location.
    private func convertFileToCoreML(atFileURL fileURL: URL) -> VNCoreMLModel? {
        var coreMLModel: VNCoreMLModel?
        do {
            let model = try MLModel(contentsOf: fileURL)
            coreMLModel = try VNCoreMLModel(for: model)
        } catch {
            print("Error creating Core ML model: \(error)")
        }
        
        return coreMLModel
    }
}
