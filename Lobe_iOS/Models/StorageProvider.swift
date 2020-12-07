//
//  StorageProvider.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/28/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import Vision


/// Storage singleton layer, used for storing and getting .mlmodel files.
class StorageProvider {
    static let shared = StorageProvider()
    
    var modelsImportedDirectory: URL {
        return self.getURL(forPath: Paths.modelsImported)
    }
    private var fileManager: FileManager
    private var appSupportURL: URL
    
    lazy var modelExample: Project = self.getModelExample()
    
    init() {
        self.fileManager = FileManager.default
        self.appSupportURL = fileManager.urls(for: .applicationSupportDirectory,                                              in: .userDomainMask).first!
        
        // Create directory if it doesn't exist
        for path in Paths.allCases {
            let directoryPath = appSupportURL.appendingPathComponent(path.rawValue)
            if !self.fileManager.fileExists(atPath: directoryPath.absoluteString, isDirectory: nil) {
                do {
                    try self.fileManager.createDirectory(at: directoryPath, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    print("Could not create directory for: \(directoryPath)\n\(error)")
                }
            }
        }
    }
    
    /// Enum used for storage locations.
    enum Paths: String, CaseIterable {
        case modelsImported
    }
    
    /// Returns full URL for given Path.
    func getURL(forPath path: Paths) -> URL {
        return appSupportURL.appendingPathComponent(path.rawValue)
    }

    /// Get list of files for imported models.
    func getImportedProjects() -> [Project] {
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

extension FileManager {
    /// Returns a Future wrapper for `replaceItemAt` method for installing models.
    func replaceItemAtFuture(_ originalItemURL: URL, withItemAt newItemURL: URL, backupItemName: String? = nil, options: FileManager.ItemReplacementOptions = []) -> Future<URL?, Error> {
        return Future { promise in
            do {
                let url = try self.replaceItemAt(originalItemURL, withItemAt: newItemURL)
                promise(.success(url))
            } catch {
                print("Could not save file: \(error)")
                promise(.failure(error))
            }
        }
    }
}
