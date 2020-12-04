//
//  StorageProvider.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/28/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import Vision

/// Storage singleton layer, used for storing and getting .mlmodel files.
class StorageProvider {
    static let shared = StorageProvider()
    
    var fileManager: FileManager
    var appSupportURL: URL
    var modelsImported: [Project] {
        get {
            return self.getImportedProjects()
        }
    }
    lazy var modelExample: Project = self.getModelExample()
    
    init() {
        self.fileManager = FileManager.default
        self.appSupportURL = fileManager.urls(for: .applicationSupportDirectory,                                              in: .userDomainMask).first!
    }
    
    /// Enum used for storage locations.
    enum Paths: String {
        case modelsImported
    }
    
    // TO-DO: Errors
    

    
    /// Add model to imported projects list.
    func saveImportedModel(for compiledModelURL: URL, fileName: String, onSuccess: (() -> Void)?) {
        self.saveFile(atPath: Paths.modelsImported, originURL: compiledModelURL, fileName: fileName, onSuccess: onSuccess)
    }
    
    /// Get list of files for imported models.
    private func getImportedProjects() -> [Project] {
        var projectList: [Project] = []
        let files = self.contentsOfDirectory(atPath: Paths.modelsImported)
        
        for fileURL in files {
            let fileName = fileURL.lastPathComponent
            let project = Project(name: fileName, modelFileURL: fileURL)
            projectList.append(project)
        }
        
        return projectList
    }
    
    /// Private helper which returns all fiels in a directory.
    private func contentsOfDirectory(atPath filePath: Paths) -> [URL] {
        var files: [URL] = []
        let path = appSupportURL.appendingPathComponent(filePath.rawValue)
        
        // Get list of projects for Application Support
        do {
            files = try fileManager.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
        } catch {
            print("Error reading file contents: \(error)")
        }
        
        return files
    }
    
    /// Private helper which saves file at specified location.
    private func saveFile(atPath filePath: Paths, originURL: URL, fileName: String, onSuccess: (() -> Void)?) {
        // Create URL for permanent location in Application Support
        let dir = appSupportURL
            .appendingPathComponent(filePath.rawValue)

        // Create Application Support path if it doesn't exist
        if !fileManager.fileExists(atPath: dir.absoluteString, isDirectory: nil) {
            do {
                try fileManager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating Application Support directory: \(error)")
            }
        }
        // Use dispatch group to notify completion
        let group = DispatchGroup()
        group.enter()

        DispatchQueue.main.async { [weak self] in
            // Copy the file to the to the permanent location, replacing it if necessary.
            do {
                let fileDestination = dir.appendingPathComponent(fileName)
                _ = try self?.fileManager.replaceItemAt(fileDestination, withItemAt: originURL)
            } catch {
                print("Error at saveFile: \(error)")
            }
        }
        group.leave()
        
        /// `notify` only calls when the above is complete.
        group.notify(queue: .main) {
            onSuccess?()
        }
    }
    
    /// Gets default model instance.
    private func getModelExample() -> Project {
        var defaultModel: VNCoreMLModel?
        let defaultModelName = "MobileNet ImageNet Classifier"
        do {
            defaultModel = try VNCoreMLModel(for: LobeModel().model)
        } catch {
            print("Error getting default project: \(error)")
        }
        let defaultProject = Project(name: defaultModelName, model: defaultModel)
        return defaultProject
    }
}
