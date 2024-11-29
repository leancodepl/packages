// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;

class NativeView implements PlatformView {
  @NonNull private final TextureView textureView;

  NativeView(@NonNull Context context, int id, @NonNull ExoPlayer exoPlayer) {
    textureView = new TextureView(context);

    textureView.setSurfaceTextureListener(
        new TextureView.SurfaceTextureListener() {
          @Override
          public void onSurfaceTextureAvailable(
              @NonNull SurfaceTexture surface, int width, int height) {
            Surface videoSurface = new Surface(surface);
            // FIXME The same thing is in VideoPlayer.java. Maybe it is the same surface?
            exoPlayer.setVideoSurface(videoSurface);
          }

          @Override
          public void onSurfaceTextureSizeChanged(
              @NonNull SurfaceTexture surface, int width, int height) {
            // FIXME Implement or remove
          }

          @Override
          public boolean onSurfaceTextureDestroyed(@NonNull SurfaceTexture surface) {
            exoPlayer.setVideoSurface(null);
            return true;
          }

          @Override
          public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            // FIXME Implement or remove
          }
        });
  }

  @NonNull
  @Override
  public View getView() {
    return textureView;
  }

  @Override
  public void dispose() {
    SurfaceTexture surfaceTexture = textureView.getSurfaceTexture();
    if (surfaceTexture != null) {
      surfaceTexture.release();
    }
    textureView.setSurfaceTextureListener(null);
  }
}
