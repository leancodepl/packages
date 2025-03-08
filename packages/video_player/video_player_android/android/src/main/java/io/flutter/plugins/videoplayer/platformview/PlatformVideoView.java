// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer.platformview;

import android.annotation.SuppressLint;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.view.TextureView;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.OptIn;
import androidx.media3.common.Player;
import androidx.media3.common.util.UnstableApi;
import androidx.media3.exoplayer.ExoPlayer;
import io.flutter.plugin.platform.PlatformView;

/**
 * A class used to create a native video view that can be embedded in a Flutter app. It wraps an
 * {@link ExoPlayer} instance and displays its video content.
 */
public final class PlatformVideoView implements PlatformView {
  @NonNull private final TextureView textureView;
  @NonNull private final Player.Listener playerListener;
  @NonNull private final ExoPlayer exoPlayer;

  /**
   * Constructs a new PlatformVideoView.
   *
   * @param context The context in which the view is running.
   * @param exoPlayer The ExoPlayer instance used to play the video.
   */
  @SuppressLint("SetTextI18n")
  @OptIn(markerClass = UnstableApi.class)
  public PlatformVideoView(@NonNull Context context, @NonNull ExoPlayer exoPlayer) {
    this.exoPlayer = exoPlayer;
    textureView = new TextureView(context);
    exoPlayer.setVideoTextureView(textureView);

    playerListener =
        new Player.Listener() {
          @Override
          public void onRenderedFirstFrame() {
            new Handler(Looper.getMainLooper())
                .postDelayed(
                    () -> {
                      boolean playingInitially = exoPlayer.getPlayWhenReady();
                      if (!playingInitially) {
                        // This ensures that the first frame is rendered even when the video is
                        // initially paused. Videos that are paused initially do not always
                        // render the first frame (blank screen is visible instead).
                        // Seeking to the current position and invalidating the view forces the
                        // rendering of a first frame.
                        exoPlayer.seekTo(exoPlayer.getCurrentPosition());
                        textureView.invalidate();
                      }
                    },
                    // A slight delay is needed to ensure that the first frame is rendered.
                    100);
          }
        };

    exoPlayer.addListener(playerListener); // Add the listener
  }

  /**
   * Returns the view associated with this PlatformView.
   *
   * @return The TextureView used to display the video.
   */
  @NonNull
  @Override
  public View getView() {
    return textureView;
  }

  /** Disposes of the resources used by this PlatformView. */
  @Override
  public void dispose() {
    exoPlayer.removeListener(playerListener);
    textureView.setSurfaceTextureListener(null);
  }
}
