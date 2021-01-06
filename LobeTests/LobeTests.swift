//
//  LobeTests.swift
//  LobeTests
//
//  Created by Elliot Boschwitz on 12/8/20.
//  Copyright © 2020 Microsoft. All rights reserved.
//

import Combine
import XCTest
@testable import Lobe

class LobeTests: XCTestCase {
    var playViewModel: PlayViewModel!
    var disposables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let openScreenViewModel = OpenScreenViewModel()
        let defaultProject = openScreenViewModel.modelExample

        guard defaultProject.model != nil else {
            XCTFail("Could not load model for default example.")
            return
        }
        self.playViewModel = PlayViewModel(project: defaultProject)
    }

//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//    }
    
    /// Tests:
    /// 1. imageFromPhotoPIcker, and ensure it equals output from camera output given same input
    /// 2. classificationResult
    /// 3. viewMode toggle

    /// Test nil input for capture session and image picker.
    func testNilImage() throws {
        self.playViewModel.captureSessionManager.capturedImageOutput = nil
        
        self.playViewModel.$classificationLabel
            .sink(receiveValue: { label in
                assert(label == "Loading Results...")
            })
            .store(in: &self.disposables)
        
        self.playViewModel.$confidence
            .sink(receiveValue: { value in
                assert(value == 0.0)
            })
            .store(in: &self.disposables)
    }
    
    /// Tests that classification label is updated in view model when image capture or image picker changes.
    func testImageUpdatesPrediction() throws {
        let receivedAllValuesLabel = expectation(description: "All values received for classification label.")
        let receivedAllValuesConfidence = expectation(description: "All values received for classification confidence.")
        var expectedResultsLabel = ["Loading Results...", "alp", "seashore, coast, seacoast, sea-coast"]
        var expectedResultsConfidence: [Float] = [0.0, 0.41130245, 0.722222]

        self.playViewModel.$classificationLabel
            .sink(receiveValue: { observedLabel in
                guard let expectedResult = expectedResultsLabel.first else {
                    assertionFailure("Expected to find comparison result but none was found.")
                    return
                }
                
                guard expectedResult == observedLabel else {
                    assertionFailure("Expected result [\(expectedResult)] did not equal observation [\(observedLabel)].")
                    return
                }
                
                // Remove first expected result after completing comparison
                expectedResultsLabel = Array(expectedResultsLabel.dropFirst())
                
                // Test is completed when there are no more expected results
                if expectedResultsLabel.isEmpty {
                    receivedAllValuesLabel.fulfill()
                }
            })
            .store(in: &self.disposables)

        self.playViewModel.$confidence
            .sink(receiveValue: { observedValue in
                guard let expectedResult = expectedResultsConfidence.first else {
                    assertionFailure("Expected to find comparison result but none was found.")
                    return
                }
                
                guard expectedResult == observedValue else {
                    assertionFailure("Expected result [\(expectedResult)] did not equal observation [\(observedValue)].")
                    return
                }
                
                // Remove first expected result after completing comparison
                expectedResultsConfidence = Array(expectedResultsConfidence.dropFirst())
                
                // Test is completed when there are no more expected results
                if expectedResultsConfidence.isEmpty {
                    receivedAllValuesConfidence.fulfill()
                }
            })
            .store(in: &self.disposables)

        let testImageYosimite = UIImage(named: "testing_image_yosemite")
        let testImageBeach = UIImage(named: "testing_image_beach")
        self.playViewModel.captureSessionManager.capturedImageOutput = testImageYosimite
        self.playViewModel.captureSessionManager.capturedImageOutput = testImageBeach
        
        // wait for receivedAllValues to be fulfilled
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testPhotoPickerUpdatesPublisher() {
        
    }
}
