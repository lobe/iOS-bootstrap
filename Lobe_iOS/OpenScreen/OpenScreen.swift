//
//  OpenScreen.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/22/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI
import Vision

/// Gets default project instance.
func getDefaultProject() -> Project? {
    var defaultProject: Project?
    let defaultModelName = "MobileNet ImageNet Classifier"
    do {
        let defaultModel = try VNCoreMLModel(for: LobeModel().model)
        defaultProject = Project(name: defaultModelName, model: defaultModel)
    } catch {
        print("Error getting default project: \(error)")
    }
    return defaultProject
}

/// Get list of imported projects.
func getImportProjectList() -> [Project] {
    var projectList: [Project] = []
    let fileManager = FileManager.default
    let appSupportURL = fileManager.urls(for: .applicationSupportDirectory,
                                         in: .userDomainMask).first!
   
    // Get list of projects for Application Support
    do {
        let storedModelFiles = try fileManager.contentsOfDirectory(atPath: appSupportURL.path)
        for fileName in storedModelFiles {
            let fileURL = appSupportURL.appendingPathComponent(fileName)
            let model = try MLModel(contentsOf: fileURL)
            let coreMLModel = try VNCoreMLModel(for: model)
            let project = Project(name: fileName, model: coreMLModel)
            projectList.append(project)
        }
    } catch {
        print("Error reading stored models: \(error)")
    }
    
    return projectList
}

/// Open Screen shows list of imorted models.
struct OpenScreen: View {
    private var projectDefault = getDefaultProject()
    private var projectListImported: [Project] = getImportProjectList()
    @State private var showProjectPicker = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(projectListImported, id: \.name) { project in
                        NavigationLink(destination: ContentView(project: project)) {
                            ProjectRow(project: project)
                        }
                    }
                }
                Section(header: Text("Example Projects")) {
                    NavigationLink(destination: ContentView(project: projectDefault)) {
                        ProjectRow(project: projectDefault)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Projects"))
            .navigationBarItems(trailing:
                                    Button("Import", action: {
                                        self.showProjectPicker.toggle()
                                    })
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showProjectPicker) {
            ProjectPicker()
        }
    }
}

struct OpenScreen_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OpenScreen()
                .preferredColorScheme(.light)
            OpenScreen()
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
                .preferredColorScheme(.dark)
        }
    }
}
