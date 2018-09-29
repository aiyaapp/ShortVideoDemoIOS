#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 音视频存储
 音频存储为.caf
 视频存储为.m4v
 */
@interface MediaWriter : NSObject

/**
 最后一帧视频画面的时间
 */
@property (nonatomic, assign, readonly) CMTime lastFramePresentationTimeStamp;

/**
 设置视频保存位置
*/
@property (nonatomic, strong) NSURL *outputVideoURL;

/**
 设置视频速度
 Range: 0.25 -> 4.0
 Default: 1.0
 */
@property (nonatomic, assign) CMTime videoSpeed;

/**
 视频宽度
 */
@property (nonatomic, assign) NSInteger videoWidth;

// 音频的速度调节只能在录制完成后进行处理.
//@property (nonatomic, assign) CMTime audioSpeed;

/**
 设置音频保存位置
 */
@property (nonatomic, strong) NSURL *outputAudioURL;

/**
 写音频数据
 */
- (void)writeAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 写视频数据
 */
- (void)writeVideoPixelBuffer:(CVPixelBufferRef)pixelBuffer time:(CMTime)frameTime;

/**
 写入完成
 */
- (void)finishWritingWithCompletionHandler:(void (^)(void))handler;

/**
 取消写入
 */
- (void)cancelWriting;

/**
 是否写入完成
 */
- (BOOL)isWriteFinish;

@end
