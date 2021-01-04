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
    /// 1. imageFromPhotoPIcker set
    /// 2. classificationResult
    /// 3. viewMode toggle

    /// Test nil input for capture session and image picker.
    func testNilImage() throws {
        self.playViewModel.captureSessionManager.capturedImageOutput = nil
        self.playViewModel.imageFromPhotoPicker = nil
        
        self.playViewModel.$classificationLabel
            .compactMap { $0 }  // remove non-nill values
            .sink(receiveValue: { label in
                assert(label == "Loading Results...")
            })
            .store(in: &self.disposables)
    }
    
    /// Tests that classification label is updated in view model when image capture or image picker changes.
    func testValidImage() throws {
        let receivedAllValues = expectation(description: "all values received")
        var expectedResults = ["Loading Results...", "alp", "seashore, coast, seacoast, sea-coast"]

        self.playViewModel.$classificationLabel
            .compactMap { $0 }  // remove non-nill values
            .sink(receiveValue: { observedLabel in
                guard let expectedResult = expectedResults.first else {
                    assertionFailure("Expected to find comparison result but none was found.")
                    return
                }
                
                guard expectedResult == observedLabel else {
                    assertionFailure("Expected result did not equal observation.")
                    return
                }
                
                // Remove first expected result after completing comparison
                expectedResults = Array(expectedResults.dropFirst())
                
                // Test is completed when there are no more expected results
                if expectedResults.isEmpty {
                    receivedAllValues.fulfill()
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
}
