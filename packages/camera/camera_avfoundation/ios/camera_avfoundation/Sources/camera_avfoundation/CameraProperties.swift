// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import UIKit

func getPigeonDeviceOrientationForOrientation(
  _ orientation: UIDeviceOrientation
) -> FCPPlatformDeviceOrientation {
  switch orientation {
  case .portraitUpsideDown:
    return .portraitDown
  case .landscapeLeft:
    return .landscapeLeft
  case .landscapeRight:
    return .landscapeRight
  case .portrait, .unknown, .faceUp, .faceDown:
    return .portraitUp
  @unknown default:
    return .portraitUp
  }
}
