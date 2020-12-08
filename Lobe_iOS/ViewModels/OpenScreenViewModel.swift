//
//  OpenScreenViewModel.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 12/7/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import SwiftUI
import Vision

/// View model for Open Screen
class OpenScreenViewModel: ObservableObject {
    @Published var modelsImported: [Project] = []
    @Published var showProjectPicker = false
    @Published var storageOperation: AnyPublisher<Void, Error>?
    var storage = StorageProvider.shared
    var modelExample: Project
    private var disposables = Set<AnyCancellable>()
    
    init() {
        // load all data
        let imageNetURL = LobeModel.urlOfModelInThisBundle
        let imageNetModel = try? LobeModel(contentsOf: imageNetURL).model
        self.modelExample = Project(name: "MobileNet ImageNet Classifier", mlModel: imageNetModel)
        self.updateImportedProjects()
        
        // Refresh view given a storage operation
        $storageOperation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.updateImportedProjects()
            })
            .store(in: &disposables)
    }
    
    /// Get list of files for imported models.
    private func updateImportedProjects() {
        var projectList: [Project] = []
        let storagePath = storage.modelsImportedDirectory
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: storagePath, includingPropertiesForKeys: nil)

            for fileURL in files {
                let fileName = fileURL.lastPathComponent
                let project = Project(name: fileName, modelFileURL: fileURL)
                projectList.append(project)
            }
        } catch {
            print("Unable to read imported projects: \(error)")
        }
        
        self.modelsImported = projectList
    }
}
