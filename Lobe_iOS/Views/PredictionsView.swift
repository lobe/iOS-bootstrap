//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI

class PredictionsViewModel: ObservableObject {
  @Published var predictions: [Prediction]
  
  init(predictions: [Prediction]) {
    self.predictions = predictions
  }
}

/// Wrapper view for each prediction label in `PlayView`.
struct PredictionsView: View {
  @ObservedObject var viewModel: PredictionsViewModel
  
  init(predictions: [Prediction]) {
    self.viewModel = PredictionsViewModel(predictions: predictions)
  }
  
  var body: some View {
    let predictions = self.viewModel.predictions

    VStack(spacing: 12) {
      if predictions.count > 0 {
        PredictionLabelView(prediction: predictions[0], isTopPrediction: true)
        if predictions.count > 1 {
          PredictionLabelView(prediction: predictions[1], isTopPrediction: false)
        }
        if predictions.count > 2 {
          PredictionLabelView(prediction: predictions[2], isTopPrediction: false)
        }
      }
    }
    .frame(minWidth: 0,
           maxWidth: .infinity, minHeight: 0,
           maxHeight: CGFloat(self.viewModel.predictions.count * 70
                                + (self.viewModel.predictions.count == 0 ? 0 : 32)),
           alignment: .top)
    .edgesIgnoringSafeArea(.all)
    .background(PlayView.blurEffect)
    .cornerRadius(40, corners: [.topLeft, .topRight])
  }
}
