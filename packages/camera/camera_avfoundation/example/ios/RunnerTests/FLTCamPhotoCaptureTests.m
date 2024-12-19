// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

@import camera_avfoundation;
#if __has_include(<camera_avfoundation/camera_avfoundation-umbrella.h>)
@import camera_avfoundation.Test;
#endif
@import AVFoundation;
@import XCTest;
#import "CameraTestUtils.h"
#import "MockCaptureDeviceController.h"
#import "MockCapturePhotoOutput.h"

/// Includes test cases related to photo capture operations for FLTCam class.
@interface FLTCamPhotoCaptureTests : XCTestCase

@end

@implementation FLTCamPhotoCaptureTests

- (void)testCaptureToFile_mustReportErrorToResultIfSavePhotoDelegateCompletionsWithError {
  XCTestExpectation *errorExpectation =
      [self expectationWithDescription:
                @"Must send error to result if save photo delegate completes with error."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);

  NSError *error = [NSError errorWithDomain:@"test" code:0 userInfo:nil];

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.capturePhotoWithSettingsStub =
      ^(id<FLTCapturePhotoSettings> settings, id<AVCapturePhotoCaptureDelegate> captureDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(nil, error);
        });
      };

  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFileWithCompletion:^(NSString *result, FlutterError *error) {
      XCTAssertNil(result);
      XCTAssertNotNil(error);
      [errorExpectation fulfill];
    }];
  });

  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCaptureToFile_mustReportPathToResultIfSavePhotoDelegateCompletionsWithPath {
  XCTestExpectation *pathExpectation =
      [self expectationWithDescription:
                @"Must send file path to result if save photo delegate completes with file path."];

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);

  NSString *filePath = @"test";

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.capturePhotoWithSettingsStub =
      ^(id<FLTCapturePhotoSettings> settings, id<AVCapturePhotoCaptureDelegate> captureDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(filePath, nil);
        });
      };
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFileWithCompletion:^(NSString *result, FlutterError *error) {
      XCTAssertEqual(result, filePath);
      [pathExpectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCaptureToFile_mustReportFileExtensionWithHeifWhenHEVCIsAvailableAndFileFormatIsHEIF {
  XCTestExpectation *expectation =
      [self expectationWithDescription:
                @"Test must set extension to heif if availablePhotoCodecTypes contains HEVC."];
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
  [cam setImageFileFormat:FCPPlatformImageFileFormatHeif];

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  // Set availablePhotoCodecTypes to HEVC
  mockOutput.availablePhotoCodecTypes = @[ AVVideoCodecTypeHEVC ];
  mockOutput.capturePhotoWithSettingsStub =
      ^(id<FLTCapturePhotoSettings> settings, id<AVCapturePhotoCaptureDelegate> photoDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(delegate.filePath, nil);
        });
      };
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFileWithCompletion:^(NSString *filePath, FlutterError *error) {
      XCTAssertEqualObjects([filePath pathExtension], @"heif");
      [expectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}

- (void)testCaptureToFile_mustReportFileExtensionWithJpgWhenHEVCNotAvailableAndFileFormatIsHEIF {
  XCTestExpectation *expectation = [self
      expectationWithDescription:
          @"Test must set extension to jpg if availablePhotoCodecTypes does not contain HEVC."];
  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);
  FLTCam *cam = FLTCreateCamWithCaptureSessionQueue(captureSessionQueue);
  [cam setImageFileFormat:FCPPlatformImageFileFormatHeif];

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.capturePhotoWithSettingsStub =
      ^(id<FLTCapturePhotoSettings> settings, id<AVCapturePhotoCaptureDelegate> photoDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(delegate.filePath, nil);
        });
      };

  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam captureToFileWithCompletion:^(NSString *filePath, FlutterError *error) {
      XCTAssertEqualObjects([filePath pathExtension], @"jpg");
      [expectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}
//
- (void)testCaptureToFile_handlesTorchMode {
  XCTestExpectation *pathExpectation =
      [self expectationWithDescription:
                @"Must send file path to result if save photo delegate completes with file path."];
  XCTestExpectation *setTorchExpectation =
      [self expectationWithDescription:@"Should set torch mode to AVCaptureTorchModeOn."];

  MockCaptureDeviceController *captureDeviceMock = [[MockCaptureDeviceController alloc] init];
  captureDeviceMock.hasTorch = YES;
  captureDeviceMock.isTorchAvailable = YES;
  captureDeviceMock.torchMode = AVCaptureTorchModeAuto;
  captureDeviceMock.setTorchModeStub = ^(AVCaptureTorchMode mode) {
    [setTorchExpectation fulfill];
  };

  dispatch_queue_t captureSessionQueue = dispatch_queue_create("capture_session_queue", NULL);
  dispatch_queue_set_specific(captureSessionQueue, FLTCaptureSessionQueueSpecific,
                              (void *)FLTCaptureSessionQueueSpecific, NULL);

  FLTCam *cam = FLTCreateCamWithCaptureSessionQueueAndMediaSettings(
      captureSessionQueue, nil, nil,
      ^id<FLTCaptureDeviceControlling>(void) {
        return captureDeviceMock;
      },
      nil, nil, nil);

  NSString *filePath = @"test";

  MockCapturePhotoOutput *mockOutput = [[MockCapturePhotoOutput alloc] init];
  mockOutput.capturePhotoWithSettingsStub =
      ^(id<FLTCapturePhotoSettings> settings, id<AVCapturePhotoCaptureDelegate> photoDelegate) {
        FLTSavePhotoDelegate *delegate = cam.inProgressSavePhotoDelegates[@(settings.uniqueID)];
        // Completion runs on IO queue.
        dispatch_queue_t ioQueue = dispatch_queue_create("io_queue", NULL);
        dispatch_async(ioQueue, ^{
          delegate.completionHandler(filePath, nil);
        });
      };
  cam.capturePhotoOutput = mockOutput;

  // `FLTCam::captureToFile` runs on capture session queue.
  dispatch_async(captureSessionQueue, ^{
    [cam setFlashMode:FCPPlatformFlashModeTorch
        withCompletion:^(FlutterError *_){
        }];
    [cam captureToFileWithCompletion:^(NSString *result, FlutterError *error) {
      XCTAssertEqual(result, filePath);
      [pathExpectation fulfill];
    }];
  });
  [self waitForExpectationsWithTimeout:1 handler:nil];
}
@end
