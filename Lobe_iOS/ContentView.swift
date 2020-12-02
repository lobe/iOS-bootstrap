//
//  ContentView.swift
//  Lobe_iOS
//
//  Created by Adam Menges on 5/20/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import SwiftUI
import AVKit
import Vision

var useCamera: Bool = true

// MARK: - Create instance of default Project
func getDefaultProject() -> Project? {
    do {
        let defaultModelName = "MobileNet ImageNet Classifier"
        let defaultModel = try VNCoreMLModel(for: LobeModel().model)
        return Project(name: defaultModelName, model: defaultModel)
    } catch {
        print(error)
    }
    return nil
}

struct ContentView: View {
    
    var controller: MyViewController = MyViewController()
    @State var showImagePicker: Bool = false
    @State private var image: UIImage?
    @State var scaling: CGSize = .init(width: 1, height: 1)
    @State private var offset = CGSize.zero
    @State private var project = getDefaultProject()
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                 if (self.image != nil) {
                    /* Placeholder for displaying an image from the photo library. */
                    Image(uiImage: self.image!)
                        .resizable()
                        .aspectRatio(self.image!.size, contentMode: .fill)
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
                                    useCamera = true
                                    self.controller.changeStatus(useCam: useCamera, img: self.controller.camImage!)
                                }
                                self.scaling = .init(width: 1, height: 1)
                            }
                        )
                        .opacity(1 / self.scaling.height < 1 ? 0.5: 1)
                } else {
                    /* Background camera. */
                    MyRepresentable(controller: self.controller, project: $project)
                        /* Gesture for swiping up the photo library. */
                        .gesture(
                            DragGesture()
                            .onEnded {value in
                                if value.translation.height < 0 {
                                    withAnimation{
                                        self.showImagePicker = true
                                    }
                                    self.controller.changeStatus(useCam: false, img: self.controller.camImage!)
                                }
                            }
                        )
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.black)
                .edgesIgnoringSafeArea(.all)
            
            HStack {
                Spacer()
                /* Icon for closing the image*/
                Image("x")
                    .resizable()
                    .opacity(self.image != nil ? 1: 0)
                    .frame(width: geometry.size.width / 15, height: geometry.size.width / 15)
                    .onTapGesture {
                        self.image = nil
                        useCamera = true
                        self.controller.changeStatus(useCam: useCamera, img: self.controller.camImage!)
                }
            }.padding()
            
            VStack {
                Spacer()
                UpdateTextViewExternal(viewModel: self.controller, project: $project)
                HStack {
                    
                    /* Button for openning the photo library. */
                    Button(action: {
                        withAnimation {
                            self.showImagePicker = true
                        }
                        self.controller.changeStatus(useCam: false, img: self.controller.camImage!)
                    }) {
                        Image("PhotoLib")
                            .renderingMode(.original)
                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 16)
                    }.opacity(0)  // not displaying the button

                    /* button for taking screenshot. */
                    Button(action: {
                        self.controller.screenShotMethod()
                    }) {
                        Image("Button")
                            .renderingMode(.original)
                            .frame(width: geometry.size.width / 3, height: geometry.size.width / 9)
                    }.opacity(0)  // not displaying the button
                    
                    /* button for flipping the camera. */
                    Button(action: {
                        self.controller.flipCamera()
                    }) {
                        Image("Swap")
                            .renderingMode(.original)
                            .frame(width: geometry.size.width / 3, height: geometry.size.height / 16)
                    }.opacity(0)  // not displaying the button
                }
                .frame(width: geometry.size.width,
                      height: geometry.size.height / 30, alignment: .bottom)
                    .opacity(self.image == nil ? 1: 0)  // hide the buttons when displaying an image from the photo library
            }

            ImagePicker(image: self.$image, isShown: self.$showImagePicker, controller: self.controller, sourceType: .photoLibrary)
                .edgesIgnoringSafeArea(.all)
                .offset(x: 0, y: self.showImagePicker ? 0: UIApplication.shared.keyWindow?.frame.height ?? 0)
        }.statusBar(hidden: true)
    }
}

/* Gadget to build colors from Hashtag Color Code Hex. */
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
