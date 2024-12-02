package io.flutter.plugins.videoplayer;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.VisibleForTesting;
import androidx.media3.common.MediaItem;
import androidx.media3.exoplayer.ExoPlayer;

import io.flutter.view.TextureRegistry;

final class VideoPlayerTextureApproach extends VideoPlayer implements TextureRegistry.SurfaceProducer.Callback {
  @NonNull private final TextureRegistry.SurfaceProducer surfaceProducer;

  /**
   * Creates a video player.
   *
   * @param context application context.
   * @param events event callbacks.
   * @param surfaceProducer produces a texture to render to.
   * @param asset asset to play.
   * @param options options for playback.
   * @return a video player instance.
   */
  @NonNull
  static VideoPlayerTextureApproach create(
      @NonNull Context context,
      @NonNull VideoPlayerCallbacks events,
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer,
      @NonNull VideoAsset asset,
      @NonNull VideoPlayerOptions options) {
    return new VideoPlayerTextureApproach(
        () -> {
          ExoPlayer.Builder builder =
              new ExoPlayer.Builder(context)
                  .setMediaSourceFactory(asset.getMediaSourceFactory(context));
          return builder.build();
        },
        events,
        surfaceProducer,
        asset.getMediaItem(),
        options);
  }

  @VisibleForTesting
  VideoPlayerTextureApproach(
      @NonNull ExoPlayerProvider exoPlayerProvider,
      @NonNull VideoPlayerCallbacks events,
      @NonNull TextureRegistry.SurfaceProducer surfaceProducer,
      @NonNull MediaItem mediaItem,
      @NonNull VideoPlayerOptions options) {
    super(exoPlayerProvider, events, mediaItem, options);

    this.surfaceProducer = surfaceProducer;
    surfaceProducer.setCallback(this);

    this.exoPlayer.setVideoSurface(surfaceProducer.getSurface());
  }


  void dispose() {
    surfaceProducer.release();
    // TODO(matanlurey): Remove when embedder no longer calls-back once released.
    // https://github.com/flutter/flutter/issues/156434.
    surfaceProducer.setCallback(null);

    super.dispose();
  }

}
