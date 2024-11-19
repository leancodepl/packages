// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import "FVPVideoPlayer.h"

@interface FVPNativeVideoViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
               playersByTextureId:
                   (NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *)playersByTextureId;
@end