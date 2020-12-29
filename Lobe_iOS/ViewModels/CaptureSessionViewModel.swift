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
    @Published var captureDevice: AVCaptureDevice?
    @Published var isEnabled = false
    @Published var previewLayer: AVCaptureVideoPreviewLayer?
    let predictionLayer: PredictionLayer
    var captureSession: AVCaptureSession?
    var backCam: AVCaptureDevice?
    var frontCam: AVCaptureDevice?
    var dataOutput: AVCaptureVideoDataOutput?
    private var disposables = Set<AnyCancellable>()
    
    init(predictionLayer: PredictionLayer) {
        self.predictionLayer = predictionLayer
        
        /// Init devices.
        self.backCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices.first
        self.frontCam = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first
        self.captureDevice = backCam
        
        /// Reset camera feed if capture device changes.
        $captureDevice
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let isEnabled = self?.isEnabled else  {
                    return
                }
                if isEnabled { self?.resetCameraFeed() }
            })
            .store(in: &disposables)
        
        /// Reset camera feed if capture session is enabled, or tear-down if disabled.
        $isEnabled
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _isEnabled in
                if _isEnabled { self?.resetCameraFeed() }
                else {
                    /// On disable, stop running capture session and then tear down.
                    /// Both steps are required to prroperly shut down camera session.
                    self?.captureSession?.stopRunning()
                    self?.captureSession = nil
                }
            })
            .store(in: &disposables)
    }
    
    /// Resets camera feed, which:
    /// 1. Creates capture session for specified device.
    /// 2. Creates preview layer.
    /// 3. Creates new video data output.
    /// 4. Starts capture session.
    func resetCameraFeed() {
        guard let captureDevice = self.captureDevice else {
            print("No capture device found on reset camera feed.")
            return
        }
        /// Tear down existing capture session to remove output for buffer delegate.
        self.captureSession = nil
        self.dataOutput = nil

        /// Create new capture session and preview layer.
        let captureSession = self.createCaptureSession(for: captureDevice)
        let previewLayer = self.createPreviewLayer(for: captureSession)
        let dataOutput = AVCaptureVideoDataOutput()

        /// Set delegate of video output buffer to the prediction layer, which handles all inference logic
        /// from the input buffer.
        dataOutput.setSampleBufferDelegate(self.predictionLayer, queue: DispatchQueue(label: "videoQueue"))
        captureSession.startRunning()
        captureSession.addOutput(dataOutput)
        
        self.captureSession = captureSession
        self.previewLayer = previewLayer
        self.dataOutput = dataOutput
    }
    
    /// Creates a capture session given input device as param.
    private func createCaptureSession(for captureDevice: AVCaptureDevice) -> AVCaptureSession {
        let captureSession = AVCaptureSession()

        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
        } catch {
            print("Could not create AVCaptureDeviceInput in viewDidLoad.")
        }
        
        return captureSession
    }
    
    /// Sets up preview layer which gets displayed in view controller.
    func createPreviewLayer(for captureSession: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return previewLayer
    }
    
    // TO-DO
    func rotateCamera() {
//        self.captureSession?.stopRunning()
        self.captureDevice = (captureDevice == backCam) ? frontCam : backCam

//        self.createCaptureSession(for: self.captureDevice)
    }
}
