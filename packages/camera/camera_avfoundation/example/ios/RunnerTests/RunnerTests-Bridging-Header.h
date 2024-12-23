// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "camera_avfoundation/FLTCam.h"
#import "camera_avfoundation/FLTCam_Test.h"
#import "camera_avfoundation/CameraPlugin.h"
#import "camera_avfoundation/CameraPlugin_Test.h"
#import "camera_avfoundation/FLTCamConfiguration.h"
#import "camera_avfoundation/FLTSavePhotoDelegate.h"
#import "camera_avfoundation/FLTSavePhotoDelegate_Test.h"
#import "camera_avfoundation/FLTThreadSafeEventChannel.h"

// Test mocks and protocols
#import "MockAssetWriter.h"
#import "MockCaptureDeviceController.h"
#import "MockCaptureSession.h"
#import "MockCameraDeviceDiscovery.h"
#import "MockCapturePhotoOutput.h"
#import "MockCapturePhotoSettings.h"
#import "MockPhotoData.h"
#import "MockCaptureConnection.h"
#import "MockDeviceOrientationProvider.h"
#import "MockEventChannel.h"
