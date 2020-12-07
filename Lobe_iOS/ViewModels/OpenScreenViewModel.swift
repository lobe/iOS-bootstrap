//
//  OpenScreenViewModel.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 12/7/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import SwiftUI

/// View model for Open Screen
class OpenScreenViewModel: ObservableObject {
    @Published var modelsImported: [Project]
    @Published var showProjectPicker = false
    @Published var storageOperation: AnyPublisher<Void, Error>?
    var modelExample = StorageProvider.shared.modelExample
    private var disposables = Set<AnyCancellable>()
    
    init() {
        self.modelsImported = StorageProvider.shared.getImportedProjects()
        
        // Refresh view given a storage operation
        $storageOperation
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.modelsImported = StorageProvider.shared.getImportedProjects()
            })
            .store(in: &disposables)
    }
}
