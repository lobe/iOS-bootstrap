//
//  ProjectPickerViewController.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/1/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import CoreML
import SwiftUI
import UIKit
import Vision

// MARK: - View controller for document picker
class ProjectPickerViewController: UIDocumentPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - Coordinator class for documenter picker.
struct ProjectPicker: UIViewControllerRepresentable {
    // dismisses view when document is selected
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var modelsImported: [Project]
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let projectPicker = ProjectPickerViewController(documentTypes: ["public.data", "public.item"], in: .import)
        projectPicker.delegate = context.coordinator
        return projectPicker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate, UINavigationControllerDelegate {
        var parent: ProjectPicker
        
        init(_ parent: ProjectPicker) {
            self.parent = parent
        }

        /// Updates model after file selected.
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if !urls.isEmpty {
                let url = urls[0]
                do {
                    defer { parent.presentationMode.wrappedValue.dismiss() }
                    
                    // Compile model on device
                    let fileName = url.lastPathComponent
                    let compiledUrl = try MLModel.compileModel(at: url)
                    
                    // Save compiled model to permanent location on device
                    StorageProvider.shared.saveImportedModel(for: compiledUrl, fileName: fileName, onSuccess: {
                        self.parent.modelsImported = StorageProvider.shared.modelsImported
                    })
                } catch {
                    print("Error compiling model: \(error)")
                }
                
            } else {
                print("Error: no URLS found.")
            }
        }
    }
}
