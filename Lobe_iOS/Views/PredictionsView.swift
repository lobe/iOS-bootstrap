//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI

class PredictionsViewModel: ObservableObject {
  @Published var predictionFirst: Prediction?
  @Published var predictionSecond: Prediction?
  @Published var predictionThird: Prediction?
  @Published var predictionsCount: Int
  
  init(predictions: [Prediction]) {
    self.predictionFirst = predictions[safe: 0]
    self.predictionSecond = predictions[safe: 1]
    self.predictionThird = predictions[safe: 2]
    self.predictionsCount = min(predictions.count, 3)
  }
}

/// Wrapper view for each prediction label in `PlayView`.
struct PredictionsView: View {
  @ObservedObject var viewModel: PredictionsViewModel
  
  init(predictions: [Prediction]) {
    self.viewModel = PredictionsViewModel(predictions: predictions)
  }
  
  var body: some View {
    VStack(spacing: 12) {
      PredictionLabelView(prediction: self.viewModel.predictionFirst, isTopPrediction: true)
      PredictionLabelView(prediction: self.viewModel.predictionSecond, isTopPrediction: false)
      PredictionLabelView(prediction: self.viewModel.predictionThird, isTopPrediction: false)
    }
    .frame(minWidth: 0,
           maxWidth: .infinity, minHeight: 0,
           maxHeight: CGFloat(self.viewModel.predictionsCount * 70
                                + (32 * min(self.viewModel.predictionsCount, 1))),
           alignment: .top)
    .edgesIgnoringSafeArea(.all)
    .background(PlayView.blurEffect)
    .cornerRadius(40, corners: [.topLeft, .topRight])
  }
}

struct PredictionsViewExternal_Previews: PreviewProvider {
  static var previews: some View {
    GeometryReader { geometry in
      ZStack(alignment: .center) {
        Image("testing_image")
          .resizable()
          .aspectRatio(contentMode: .fill)
          .edgesIgnoringSafeArea(.all)
          .frame(width: geometry.size.width,
                 height: geometry.size.height)
        PredictionsView(predictions: [
          Prediction(label: "Primary Prediction", confidence: 0.6),
          Prediction(label: "Secondary", confidence: 0.2),
          Prediction(label: "Third", confidence: 0.1)
        ])
      }.frame(width: geometry.size.width,
              height: geometry.size.height)
    }
  }
}
