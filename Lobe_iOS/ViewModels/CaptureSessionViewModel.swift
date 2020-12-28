//
//  CaptureSessionViewModel.swift
//  Lobe_iOS
//
//  Created by Elliot Boschwitz on 12/27/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import AVKit
import Combine
import SwiftUI

/// View model for camera view.
class CaptureSessionViewModel: ObservableObject {
    @Published var captureSession: AVCaptureSession?
    @Published var captureDevice: AVCaptureDevice?
    @Published var isEnabled = false
    private var backCam: AVCaptureDevice?
    private var frontCam: AVCaptureDevice?
    private var disposables = Set<AnyCancellable>()
    
    init() {
        self.backCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
        self.frontCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
        
        self.captureDevice = backCam
        self.captureSession = AVCaptureSession()
        
        $captureDevice
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: createCaptureSession(for:))
            .store(in: &disposables)
        
        $isEnabled
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _isEnabled in
                if (_isEnabled) {
                    self.createCaptureSession(for: self.captureDevice)
                } else {
                    self.captureSession?.stopRunning()
                }
            })
            .store(in: &disposables)
    }
    
    func createCaptureSession(for captureDevice: AVCaptureDevice?) {
        guard self.isEnabled else {
            print("Capture session disabled.")
            return
        }

        let captureSession = AVCaptureSession()

        guard let captureDevice = captureDevice
        else {
            print("Could not start capture session.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Could not create AVCaptureDeviceInput in viewDidLoad.")
        }
        
        captureSession.startRunning()
        self.captureSession = captureSession
        
        // TO-DO
//        setPreviewLayer()
//        setOutput()
    }
    
    // TO-DO
    func rotateCamera() {
//        self.captureSession?.stopRunning()
        self.captureDevice = (captureDevice == backCam) ? frontCam : backCam

//        self.createCaptureSession(for: self.captureDevice)
    }
}
