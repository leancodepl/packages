// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import XCTest
import camera_avfoundation
import Flutter

// TODO(mchudy): think how to do this in a better way
extension FLTThreadSafeEventChannel: @unchecked @retroactive Sendable {}
extension MockEventChannel: @unchecked @retroactive Sendable {}

@MainActor
final class ThreadSafeEventChannelTests: XCTestCase {
  private var mockEventChannel: MockEventChannel!
  private var threadSafeEventChannel: FLTThreadSafeEventChannel!
  
  override func setUp() async throws {
    mockEventChannel = MockEventChannel()
    threadSafeEventChannel = FLTThreadSafeEventChannel(eventChannel: mockEventChannel)
  }
  
  func testSetStreamHandler_shouldStayOnMainThreadIfCalledFromMainThread() async {
    let mainThreadExpectation = expectation(description: "setStreamHandler must be called on the main thread")
    let mainThreadCompletionExpectation = expectation(description: "setStreamHandler's completion block must be called on the main thread")
    
    mockEventChannel.setStreamHandlerStub = { handler in
      if Thread.isMainThread {
        mainThreadExpectation.fulfill()
      }
    }
    
    threadSafeEventChannel.setStreamHandler(nil) {
      if Thread.isMainThread {
        mainThreadCompletionExpectation.fulfill()
      }
    }
    
    await fulfillment(of: [mainThreadExpectation, mainThreadCompletionExpectation], timeout: 1)
  }
  
  func testSetStreamHandler_shouldDispatchToMainThreadIfCalledFromBackgroundThread() async {
    let mainThreadExpectation = expectation(description: "setStreamHandler must be called on the main thread")
    let mainThreadCompletionExpectation = expectation(description: "setStreamHandler's completion block must be called on the main thread")
    
    mockEventChannel.setStreamHandlerStub = { handler in
      if Thread.isMainThread {
        mainThreadExpectation.fulfill()
      }
    }
    
    let dispatchQueue = DispatchQueue.global(qos: .default)
    dispatchQueue.async { [weak threadSafeEventChannel] in
      threadSafeEventChannel!.setStreamHandler(nil) {
        if Thread.isMainThread {
          mainThreadCompletionExpectation.fulfill()
        }
      }
    }
    
    await fulfillment(of: [mainThreadExpectation, mainThreadCompletionExpectation], timeout: 1)
  }
  
  func testEventChannel_shouldBeKeptAliveWhenDispatchingBackToMainThread() async {
    let expectation = expectation(description: "Completion should be called")
    
    let backgroundQueue = DispatchQueue(label: "test")
    backgroundQueue.async { [weak mockEventChannel] in
      let channel = FLTThreadSafeEventChannel(eventChannel: mockEventChannel!)
      channel.setStreamHandler(nil) {
        expectation.fulfill()
      }
    }
    
    await fulfillment(of: [expectation], timeout: 1)
  }
}
