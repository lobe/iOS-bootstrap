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
                        ZStack {
                            CameraView(captureSessionManager: self.viewModel.captureSessionManager)
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
                        }

                    // Placeholder for displaying an image from the photo library.
                    case .ImagePreview:
                        ImagePreview(image: self.$viewModel.imageFromPhotoPicker, viewMode: self.$viewModel.viewMode)
                        
                    // TO-DO: loading screen here
                    case .NotLoaded:
                        Text("View Loading...")
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)

            VStack {
                /// Show processed image that gets used for prediction.
                /// Used for debugging purposes
                if Bool(ProcessInfo.processInfo.environment["SHOW_FORMATTED_IMAGE"] ?? "false") ?? false {
                    if let imageForProcessing = self.viewModel.imagePredicter.imageForPrediction {
                        Image(uiImage: imageForProcessing)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                            .border(Color.blue, width: 8)
                    }
                }
                Spacer()
                PredictionLabelView(classificationLabel: self.$viewModel.classificationLabel, confidence: self.$viewModel.confidence, projectName: self.viewModel.project.name)
            }
        }
        .statusBar(hidden: true)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: openScreenButton, trailing:
            HStack {
                /// Render `rotateCameraButton` for all modes--this is a workaround for bug where right padding is off for `ImagePreview` mode.
                rotateCameraButton
                    .disabled(self.viewModel.viewMode != .Camera)
                    .opacity(self.viewModel.viewMode == .Camera ? 1 : 0)
                /// Photo picker button if in camera mode, else we show button to toggle to camera mode
                if (self.viewModel.viewMode == .Camera) {
                    openPhotoPickerButton
                } else {
                    showCameraModeButton
                }
            }
                                .buttonStyle(PlayViewButtonStyle())
        )
        .sheet(isPresented: self.$viewModel.showImagePicker) {
            ImagePicker(image: self.$viewModel.imageFromPhotoPicker, viewMode: self.$viewModel.viewMode, predictionLayer: self.viewModel.imagePredicter, sourceType: .photoLibrary)
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear {
            self.viewModel.viewMode = .Camera
        }
        .onDisappear {
            /// Disable capture session
            self.viewModel.viewMode = .NotLoaded
        }
    }
}

extension PlayView {
    /// Button style for navigation row
    struct PlayViewButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(10)
                .foregroundColor(.white)
                .background(Color.black.opacity(0.35).blur(radius: 20))
                .cornerRadius(8)
        }
    }

    /// Button for return back to open screen
    var openScreenButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Projects")
            }
        }
        .buttonStyle(PlayViewButtonStyle())
    }
    
    /// Button for opening photo picker
    var openPhotoPickerButton: some View {
        Button(action: {
            self.viewModel.showImagePicker.toggle()
        }) {
            Image(systemName: "photo.fill")
        }
    }
    
    /// Button for enabling camera mode
    var showCameraModeButton: some View {
        Button(action: {
            self.viewModel.viewMode = .Camera
        }) {
            Image(systemName: "camera.viewfinder")
        }
    }
    
    /// Button for rotating camera
    var rotateCameraButton: some View {
        Button(action: { self.viewModel.captureSessionManager.rotateCamera() }) {
            Image(systemName: "camera.rotate.fill")
        }
    }
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
    struct TestImage: View {
        var body: some View {
            Image("testing_image")
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    static var previews: some View {
        let viewModel = PlayViewModel(project: Project(name: "Test", model: nil))
        viewModel.viewMode = .Camera

        return Group {
            NavigationView {
                ZStack {
                    TestImage()
                    PlayView(viewModel: viewModel)
                }
            }
            .previewDevice("iPhone 12")
            ZStack {
                TestImage()
                PlayView(viewModel: viewModel)
            }
            .previewDevice("iPad Pro (11-inch) (2nd generation)")
        }
    }
}
