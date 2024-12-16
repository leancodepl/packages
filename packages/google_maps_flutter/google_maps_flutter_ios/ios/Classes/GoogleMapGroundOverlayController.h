// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Flutter/Flutter.h>
#import <GoogleMaps/GoogleMaps.h>
#import "GoogleMapController.h"

// Defines ground overlay UI options writable from Flutter.
@protocol FLTGoogleMapGroundOverlayOptionsSink
- (void)setBearing:(CLLocationDirection)bearing;
- (void)setBitmapDescriptor:(UIImage *)bd;
- (void)setBounds:(GMSCoordinateBounds *)bounds;
- (void)setConsumeTapEvents:(BOOL)consume;
- (void)setPosition:(CLLocationCoordinate2D)position width:(CGFloat)width height:(CGFloat)height;
- (void)setOpacity:(float)opacity;
- (void)setVisible:(BOOL)visible;
- (void)setZIndex:(int)zIndex;
@end

// Defines ground overlay controllable by Flutter.
@interface FLTGoogleMapGroundOverlayController : NSObject <FLTGoogleMapGroundOverlayOptionsSink>
@property(atomic, readonly) NSString *groundOverlayId;
- (instancetype)initGroundOverlayWithPosition:(CLLocationCoordinate2D)position
                                         icon:(UIImage *)icon
                              groundOverlayId:(NSString *)groundOverlayId
                                      mapView:(GMSMapView *)mapView;
- (instancetype)initGroundOverlayWithBounds:(GMSCoordinateBounds *)bounds
                                       icon:(UIImage *)icon
                            groundOverlayId:(NSString *)groundOverlayId
                                    mapView:(GMSMapView *)mapView;
- (BOOL)consumeTapEvents;
- (void)removeGroundOverlay;
@end

@interface FLTGroundOverlaysController : NSObject
- (instancetype)initWithMapView:(GMSMapView *)mapView
                callbackHandler:(FGMMapsCallbackApi *)callbackHandler
                      registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addGroundOverlays:(NSArray<FGMPlatformGroundOverlay *> *)groundOverlaysToAdd;
- (void)changeGroundOverlays:(NSArray<FGMPlatformGroundOverlay *> *)groundOverlaysToChange;
- (void)removeGroundOverlayWithIdentifiers:(NSArray<NSString *> *)groundOverlayIdsToRemove;
- (void)onGroundOverlayTap:(NSString *)groundOverlayId;
- (bool)hasGroundOverlayWithIdentifier:(NSString *)groundOverlayId;
- (void)didTapGroundOverlayWithIdentifier:(NSString *)identifier;
@end