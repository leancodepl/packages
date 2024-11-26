#import <AVFoundation/AVFoundation.h>

// Protocol for AVFoundation object instance factory. Used for injecting framework objects in tests.
@protocol FVPAVFactory
@required
- (AVPlayer *)playerWithPlayerItem:(AVPlayerItem *)playerItem;
- (AVPlayerItemVideoOutput *)videoOutputWithPixelBufferAttributes:
    (NSDictionary<NSString *, id> *)attributes;
@end

@interface FVPDefaultAVFactory : NSObject <FVPAVFactory>
@end