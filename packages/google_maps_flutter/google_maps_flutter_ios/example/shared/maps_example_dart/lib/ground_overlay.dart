// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'example_google_map.dart';
import 'page.dart';

class GroundOverlayPage extends GoogleMapExampleAppPage {
  const GroundOverlayPage({Key? key})
      : super(const Icon(Icons.map), 'Ground overlay', key: key);

  @override
  Widget build(BuildContext context) {
    return const GroundOverlayBody();
  }
}

class GroundOverlayBody extends StatefulWidget {
  const GroundOverlayBody({super.key});

  @override
  State<StatefulWidget> createState() => GroundOverlayBodyState();
}

class GroundOverlayBodyState extends State<GroundOverlayBody> {
  GroundOverlayBodyState();

  ExampleGoogleMapController? controller;
  AssetMapBitmap? _overlayImage;
  double _bearing = 0;
  double _opacity = 0.0;
  final bool _scalingEnabled = true;
  final bool _mipMapsEnabled = true;

  // ignore: use_setters_to_change_properties
  void _onMapCreated(ExampleGoogleMapController controller) {
    this.controller = controller;
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _removeGroundOverlay() {
    setState(() {
      _overlayImage = null;
    });
  }

  Future<void> _addGroundOverlay(BuildContext context) async {
    // Width and height are used only for custom size.
    final (double? width, double? height) = (null, null);

    AssetMapBitmap assetMapBitmap;
    if (_mipMapsEnabled) {
      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);

      assetMapBitmap = await AssetMapBitmap.create(
        imageConfiguration,
        'assets/red_square.png',
        width: width,
        height: height,
        bitmapScaling:
            _scalingEnabled ? MapBitmapScaling.auto : MapBitmapScaling.none,
      );
    } else {
      // Uses hardcoded asset path
      // This bypasses the asset resolving logic and allows to load the asset
      // with precise path.

      final ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context);

      assetMapBitmap = await AssetMapBitmap.create(
        imageConfiguration,
        'assets/red_square.png',
        width: width,
        height: height,
        bitmapScaling:
            _scalingEnabled ? MapBitmapScaling.auto : MapBitmapScaling.none,
      );
    }

    setState(() {
      _overlayImage = assetMapBitmap;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Set<GroundOverlay> overlays = <GroundOverlay>{
      if (_overlayImage != null)
        GroundOverlay.fromPosition(
          groundOverlayId: const GroundOverlayId('ground_overlay_1'),
          bitmap: _overlayImage,
          position: const LatLng(59.935460, 30.325177),
          width: 2000,
          height: 1000,
          bearing: _bearing,
          opacity: _opacity,
          zIndex: 1000,
        ),

      /// Uncomment to add a ground overlay with bounds
      // if (_overlayImage != null)
      //   GroundOverlay.fromBounds(
      //     LatLngBounds(
      //         southwest: const LatLng(59, 30), northeast: const LatLng(60, 31)),
      //     groundOverlayId: const GroundOverlayId('ground_overlay_3'),
      //     bitmap: _overlayImage,
      //     opacity: _opacity,
      //     zIndex: 21,
      //   ),
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: 350.0,
            height: 500.0,
            child: ExampleGoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(59.935460, 30.325177),
                zoom: 15.0,
              ),
              groundOverlays: overlays,
              onMapCreated: _onMapCreated,
            ),
          ),
        ),
        ...<Widget>[
          if (overlays.isEmpty)
            TextButton(
              onPressed: () => _addGroundOverlay(context),
              child: const Text('Add ground overlay'),
            ),
          if (overlays.isNotEmpty)
            TextButton(
              onPressed: _removeGroundOverlay,
              child: const Text('Remove ground overlay'),
            ),
          if (overlays.isNotEmpty)
            const Padding(padding: EdgeInsets.all(8), child: Text('Bearing')),
          if (overlays.isNotEmpty)
            Slider(
              label: 'Bearing',
              value: _bearing,
              max: 360,
              onChanged: (double value) {
                setState(() {
                  _bearing = value;
                });
              },
            ),
          if (overlays.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Opacity'),
            ),
          if (overlays.isNotEmpty)
            Slider(
              label: 'Opacity',
              value: _opacity * 100,
              max: 100,
              onChanged: (double value) {
                setState(() {
                  _opacity = value / 100.0;
                });
              },
            ),
        ],
      ],
    );
  }
}
