//
//  OpenScreen.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/22/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI

/// Open Screen shows list of imorted models.
struct OpenScreen: View {
    private var modelExample = StorageProvider.shared.modelExample
    @State private var showProjectPicker = false
    @State private var modelsImported = StorageProvider.shared.modelsImported
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(modelsImported, id: \.name) { project in
                        NavigationLink(destination: PlayView(project: project)) {
                            ProjectRow(project: project)
                        }
                    }
                }
                Section(header: Text("Example Projects")) {
                    NavigationLink(destination: PlayView(project: modelExample)) {
                        ProjectRow(project: modelExample)
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
            ProjectPicker(modelsImported: $modelsImported)
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
