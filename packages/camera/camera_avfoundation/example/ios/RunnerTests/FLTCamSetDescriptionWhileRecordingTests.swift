// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import XCTest

@testable import camera_avfoundation

final class FLTCamSetDescriptionWhileRecordingTests: XCTestCase {
//  private func createCamera() -> (FLTCam, MockCaptureDevice) {
//    let mockDevice = MockCaptureDevice()
//
//    let configuration = FLTCreateTestCameraConfiguration()
//    configuration.captureDeviceFactory = { _ in mockDevice }
////    configuration.deviceOrientationProvider = MockDeviceOrientationProvider()
//    let camera = FLTCreateCamWithConfiguration(configuration)
//
//    return (camera, mockDevice)
//  }

  func testSetDescriptionWhileRecording_ReturnsError_IfNotRecording() {
    let camera = FLTCreateCamWithConfiguration(FLTCreateTestCameraConfiguration())
    
    let expectation = expectation(description: "Call completed");

    camera.setDescriptionWhileRecording("camera_name") { error in
      XCTAssertNotNil(error)
      XCTAssertEqual(error?.code, "setDescriptionWhileRecordingFailed")
      XCTAssertEqual(error?.message, "Device was not recording")
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 30)
  }
  
  func testSetDescriptionWhileRecording_CreatesNewCaptureDevice() {
    let configuration = FLTCreateTestCameraConfiguration();
    let mockDevice = MockCaptureDevice()

    let targetCameraName = "target_camera_name"
    
    var captureDeviceFactoryWithTargetCameraNameCalled = false
  
    configuration.captureDeviceFactory = { cameraName in
      if (cameraName == targetCameraName) {
        captureDeviceFactoryWithTargetCameraNameCalled = true
      }
      return mockDevice
    }

    let camera = FLTCreateCamWithConfiguration(configuration)
    
    let recordingStartedExpectation = expectation(description: "Recording started");
    
    // Start recording
    camera.startVideoRecording(completion: { error in
      XCTAssertNil(error)
      recordingStartedExpectation.fulfill()
    }, messengerForStreaming: nil)
    
    wait(for: [recordingStartedExpectation], timeout: 30)
    
    let callCompletedExpectation = expectation(description: "Call completed");
     
    camera.setDescriptionWhileRecording(targetCameraName) { error in
      XCTAssertNil(error)
      callCompletedExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 30)
    
    XCTAssertTrue(captureDeviceFactoryWithTargetCameraNameCalled)
  }
  
  func testSetDescriptionWhileRecording_RemovesOldInputAndOutput() {
    let mockVideoCaptureSession = MockCaptureSession()
    let configuration = FLTCreateTestCameraConfiguration();
  
    configuration.videoCaptureSession = mockVideoCaptureSession
    mockVideoCaptureSession.canSetSessionPreset = true
    mockVideoCaptureSession.canAddInputStub = { _ in
      return true
    }
    
    let camera = FLTCreateCamWithConfiguration(configuration)
    
    let recordingStartedExpectation = expectation(description: "Recording started");
    
    // Start recording
    camera.startVideoRecording(completion: { error in
      XCTAssertNil(error)
      recordingStartedExpectation.fulfill()
    }, messengerForStreaming: nil)
    
    wait(for: [recordingStartedExpectation], timeout: 30)
    
    let callCompletedExpectation = expectation(description: "Call completed");
    
    camera.setDescriptionWhileRecording("new_camera_name") { error in
      XCTAssertNil(error)
      callCompletedExpectation.fulfill()
    }
    
    waitForExpectations(timeout: 30)
    
  }
}
