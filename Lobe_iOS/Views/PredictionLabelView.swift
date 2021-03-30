//
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Foundation
import SwiftUI

struct VisualEffectView: UIViewRepresentable {
  var effect: UIVisualEffect?
  func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
  func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

/* View for displaying the green bar containing the prediction label. */
struct PredictionLabelView: View {
  var prediction: Prediction?
  private var backgroundColor: Color = Color.white
  private var opacity: Double = 0
  private var paddingTop: CGFloat = 0
  
  init(prediction: Prediction?, isTopPrediction: Bool) {
    self.prediction = prediction
    self.backgroundColor = isTopPrediction ? Color(UIColor(rgb: 0x00DDB3)) : Color.white
    self.opacity = (prediction == nil) ? 0 : (isTopPrediction ? 1 : 0.2)
    self.paddingTop = isTopPrediction ? 16 : 0
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center) {
        HStack(alignment: .center) {
          ZStack (alignment: .leading) {
            // TODO: Add animations.
            Rectangle()
              .frame(width: max(min(CGFloat(self.prediction?.confidence ?? 0) * geometry.size.width, geometry.size.width), 46))
              .foregroundColor(self.backgroundColor)
              .cornerRadius(23)
              .opacity(self.opacity)
              .animation(.spring())

            Text(self.prediction?.label ?? "")
              .font(.system(size: 32))
              .fontWeight(.medium)
              .foregroundColor(.white)
              .padding(.leading, 16)
          }
        }
      }
    }
    .frame(width: UIScreen.main.bounds.width - 32,
           height: 58,
           alignment: .center
    )
    .padding(.top, self.paddingTop)
  }
}

struct UpdateTextViewExternal_Previews: PreviewProvider {
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
