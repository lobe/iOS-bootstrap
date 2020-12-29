//
//  PlayView.swift
//  Lobe_iOS
//
//  Created by Adam Menges on 5/20/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import SwiftUI

struct PlayView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: PlayViewModel
    
    init(viewModel: PlayViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                switch(self.viewModel.viewMode) {
                    // Background camera view.
                    case .Camera:
                        CameraView(viewModel: viewModel)
                        // Gesture for swiping up the photo library.
                        .gesture(
                            DragGesture()
                                .onEnded {value in
                                    if value.translation.height < 0 {
                                        withAnimation{
                                            self.viewModel.showImagePicker.toggle()
                                        }
                                    }
                                }
                        )

                    // Placeholder for displaying an image from the photo library.
                    case .ImagePreview:
                        ImagePreview(image: self.$viewModel.image, viewMode: self.$viewModel.viewMode)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                PredictionLabelView(classificationLabel: self.$viewModel.classificationLabel, confidence: self.$viewModel.confidence, projectName: self.viewModel.project.name)
            }
        }
        .statusBar(hidden: true)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: openScreenButton, trailing: closeImagePreviewButton)
        .sheet(isPresented: self.$viewModel.showImagePicker) {
            ImagePicker(image: self.$viewModel.image, viewMode: self.$viewModel.viewMode, sourceType: .photoLibrary)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

extension PlayView {
    /// Button for return back to open screen
    var openScreenButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "square.fill.on.square.fill")
                .scaleEffect(1.5)
                .padding()
        }
    }
    
    var closeImagePreviewButton: some View {
        let isVisible = self.viewModel.viewMode == .ImagePreview
        
        return (
            Button(action: { self.viewModel.viewMode = .Camera }) {
                Image(systemName: "xmark")
                    .scaleEffect(1.5)
                    .padding()
            }
            .opacity(isVisible ? 1 : 0)
            .disabled(!isVisible)
        )
    }
    
    
    // TO-DO: get below buttons to work again
    //                HStack {
    //
    //                    /* Button for openning the photo library. */
    //                    Button(action: {
    //                        withAnimation {
    //                            self.showImagePicker = true
    //                        }
    //                        viewModel.changeStatus(useCam: false, img: self.controller.camImage!)
    //                    }) {
    //                        Image("PhotoLib")
    //                            .renderingMode(.original)
    //                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 16)
    //                    }.opacity(0)  // not displaying the button
    //
    //                    /* button for taking screenshot. */
    //                    Button(action: {
    //                        self.controller.takeScreenShot()
    //                    }) {
    //                        Image("Button")
    //                            .renderingMode(.original)
    //                            .frame(width: geometry.size.width / 3, height: geometry.size.width / 9)
    //                    }.opacity(0)  // not displaying the button
    //
    //                    /* button for flipping the camera. */
    //                    Button(action: {
    //                        self.controller.flipCamera()
    //                    }) {
    //                        Image("Swap")
    //                            .renderingMode(.original)
    //                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 16)
    //                    }.opacity(0)  // not displaying the button
    //                }
    //                .frame(width: geometry.size.width,
    //                      height: geometry.size.height / 30, alignment: .bottom)
    //                .opacity(self.image == nil ? 1: 0)  // hide the buttons when displaying an image from the photo library
}

/// Gadget to build colors from Hashtag Color Code Hex.
extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
}

struct PlayView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = PlayViewModel(project: Project(name: "Test", model: nil))
        return Group {
            PlayView(viewModel: viewModel)
            PlayView(viewModel: viewModel)
                .previewDevice("iPad Pro (11-inch) (2nd generation)")
        }
    }
}
