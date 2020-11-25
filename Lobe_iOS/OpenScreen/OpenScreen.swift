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

/// Open Screen shows list of imorted models.
struct OpenScreen: View {
    private var projectListImported: [Project] = []
    private var projectDefault = getDefaultProject()
    @State private var showProjectPicker = false
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ContentView(project: projectDefault)) {
                    ProjectRow(project: projectDefault)
                }
            }
            .navigationBarTitle(Text("Lobe"))
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
