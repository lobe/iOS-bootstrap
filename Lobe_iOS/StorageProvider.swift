//
//  StorageProvider.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/28/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import Vision

/// Storage singleton layer which configures folder structure.
class StorageProvider {
    static let shared = StorageProvider()
    
    var modelsImportedDirectory: URL {
        return self.getURL(forPath: Paths.modelsImported)
    }
    var fileManager: FileManager
    private var appSupportURL: URL
    
    init() {
        self.fileManager = FileManager.default
        self.appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        
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
    private func getURL(forPath path: Paths) -> URL {
        return appSupportURL.appendingPathComponent(path.rawValue)
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
