// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import android.content.Context;
import android.graphics.SurfaceTexture;
import android.view.Surface;
import android.view.TextureView;
import android.view.View;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;
import androidx.media3.common.VideoSize;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;

class NativeView implements PlatformView {
  @NonNull private final TextureView textureView;
  private Surface videoSurface;

  NativeView(@NonNull Context context, int id, @NonNull ExoPlayer exoPlayer) {
    textureView = new TextureView(context);
    textureView.setSurfaceTextureListener(
        new TextureView.SurfaceTextureListener() {
          @Override
          public void onSurfaceTextureAvailable(
              @NonNull SurfaceTexture surface, int width, int height) {
            videoSurface = new Surface(surface);
            exoPlayer.setVideoSurface(videoSurface);
          }

          @Override
          public void onSurfaceTextureSizeChanged(SurfaceTexture surface, int width, int height) {
            // No implementation needed.
          }

          @Override
          public boolean onSurfaceTextureDestroyed(SurfaceTexture surface) {
            exoPlayer.setVideoSurface(null);
            if (videoSurface != null) {
              videoSurface.release();
              videoSurface = null;
            }
            return true;
          }

          @Override
          public void onSurfaceTextureUpdated(SurfaceTexture surface) {
            // No implementation needed.
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
    if (videoSurface != null) {
      videoSurface.release();
      videoSurface = null;
    }
  }
}
