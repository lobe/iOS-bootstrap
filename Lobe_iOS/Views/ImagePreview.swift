//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import SwiftUI

/// Shows image preview from photo library on top of PlayView.
struct ImagePreview: View {
  @Binding var image: UIImage?
  @Binding var viewMode: PlayViewMode
  @State private var offset = CGSize.zero
  @State private var scaling: CGSize = .init(width: 1, height: 1)
  
  var body: some View {
    if let image = self.image {
      Image(uiImage: image)
        .resizable()
        .aspectRatio(image.size, contentMode: .fill)
        .scaleEffect(1 / self.scaling.height)
        .offset(self.offset)
        
        /* Gesture for swiping down to dismiss the image. */
        .gesture(DragGesture()
                  .onChanged ({value in
                    self.scaling = value.translation
                    self.scaling.height = max(self.scaling.height / 50, 1)
                    self.offset = value.translation
                  })
                  .onEnded {_ in
                    self.offset = .zero
                    if self.scaling.height > 1.5 {
                      self.image = nil
                      self.viewMode = .Camera
                    }
                    self.scaling = .init(width: 1, height: 1)
                  }
        )
        .opacity(1 / self.scaling.height < 1 ? 0.5: 1)
    }
  }
}

