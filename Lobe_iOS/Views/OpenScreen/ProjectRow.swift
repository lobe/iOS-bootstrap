//
//  ProjectRow.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 11/22/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI
import Vision

// MARK: - Table Row for Open Screen
struct ProjectRow: View {
    var project: Project?

    var body: some View {
        HStack {
            Text(project?.name ?? "Error loading project")
            Spacer()
        }
    }
}

struct ProjectRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProjectRow(project: Project(name: "Test"))
            ProjectRow(project: Project(name: "Test 2"))
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
