import Foundation
import SwiftUI

struct VisualEffectView: UIViewRepresentable {
  var effect: UIVisualEffect?
  func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
  func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

/* View for displaying the green bar containing the prediction label. */
struct PredictionLabelView: View {
  @State private var showImagePicker: Bool = false
  @State var classificationLabel: String?
  @State var confidence: Float?
  @State var top: Bool = false
  
  var body: some View {
    GeometryReader { geometry in
      VStack(alignment: .center) {
        HStack(alignment: .center) {
          ZStack (alignment: .leading) {
            let color = self.top ? Color(UIColor(rgb: 0x00DDB3)) : Color.white
            let opacity = self.top ? 1 : 0.2
            let text = self.classificationLabel ?? "Loading..."
            Rectangle()
              .foregroundColor(color)
              .opacity(opacity)
              .frame(width: max(min(CGFloat(self.confidence ?? 0) * geometry.size.width / 1.2, geometry.size.width / 1.2), 46))
              .cornerRadius(23)
              .opacity(text == "Loading..." ? 0 : 1)

            Text(text)
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
    .padding(.top, self.top ? 16 : 0)
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
//        PredictionLabelView(classificationLabel: .constant(nil), confidence: .constant(nil))
      }.frame(width: geometry.size.width,
              height: geometry.size.height)
    }
  }
}
