//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import Vision

/// Project class.
struct Project {
  var model: VNCoreMLModel?
  
  /// Initialize Project instance with MLModel.
  init(mlModel: MLModel?) {
    if let mlModel = mlModel {
      self.model = try? VNCoreMLModel(for: mlModel)
    }
  }
}
