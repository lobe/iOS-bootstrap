//
//  UpdateTextViewExternal.swift
//  Lobe_iOS
//
//  Created by Kathy Zhou on 6/4/20.
//  Copyright © 2020 Adam Menges. All rights reserved.
//

import Foundation
import SwiftUI

/* View for displaying the green bar containing the prediction label. */
struct UpdateTextViewExternal: View {
    @ObservedObject var viewModel: MyViewController
    @State var showImagePicker: Bool = false
    @State private var image: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Spacer()
                HStack {
                    ZStack (alignment: .leading) {
                        
                        Rectangle()
                            .foregroundColor(Color(UIColor(rgb: 0x33987A)))
                            .opacity(0.88)
                        
                        Rectangle()
                            .foregroundColor(Color(UIColor(rgb: 0x00DDAD)))
                            .frame(width: min(CGFloat(self.viewModel.confidence ?? 0) * geometry.size.width / 1.2, geometry.size.width / 1.2))
                            .animation(.linear)
                    
                        Text(self.viewModel.classificationLabel ?? "default")
                            .padding()
                            .foregroundColor(.white)
                            .font(.custom("labgrotesque-bold", size: 28))
                    }
                }
                .frame(width: geometry.size.width / 1.2,
                       height: geometry.size.height / 13, alignment: .center)
                .cornerRadius(17.0)
                .padding()
            }
        }
    }
}
