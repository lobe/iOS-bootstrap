//
//  OpenScreen.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/22/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import SwiftUI

/// Open Screen shows list of imorted models.
struct OpenScreen: View {
    @ObservedObject var viewModel: OpenScreenViewModel
    
    init(viewModel: OpenScreenViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(viewModel.modelsImported, id: \.name) { project in
                        let playViewModel = PlayViewModel(project: project)
                        NavigationLink(destination: PlayView(viewModel: playViewModel)) {
                            ProjectRow(project: project)
                        }
                    }
                    .onDelete(perform: viewModel.deleteItems)
                }
                Section(header: Text("Example Projects")) {
                    let playViewModel = PlayViewModel(project: viewModel.modelExample)
                    NavigationLink(destination: PlayView(viewModel: playViewModel)) {
                        ProjectRow(project: viewModel.modelExample)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle(Text("Projects"))
            .navigationBarItems(trailing:
                                    Button("Import", action: {
                                        viewModel.showProjectPicker.toggle()
                                    })
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $viewModel.showProjectPicker) {
            ProjectPicker(storageOperation: self.$viewModel.storageOperation)
        }
    }
}

struct OpenScreen_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = OpenScreenViewModel()

        Group {
            OpenScreen(viewModel: viewModel)
                .preferredColorScheme(.light)
            OpenScreen(viewModel: viewModel)
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
                .preferredColorScheme(.dark)
        }
    }
}
