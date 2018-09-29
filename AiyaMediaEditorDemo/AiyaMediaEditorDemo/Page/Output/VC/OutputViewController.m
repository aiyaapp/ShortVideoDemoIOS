//
//  OutputViewController.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "OutputViewController.h"
#import "OutputView.h"
#import "MP4ReEncode.h"
#import "VideoEffectHandler.h"
#import "AppDelegate.h"
#import "MP4ReEncode.h"
#import "CompressMedia.h"

#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AiyaMediaEditor/AiyaMediaEditor.h>
#import <AVFoundation/AVFoundation.h>

@interface OutputViewController () <OutputViewDelegate, MP4ReEncodeDelegate>

@property (nonatomic, strong) OutputView *outputView;

@property (nonatomic, strong) AVAssetExportSession *mediaExporter;

// 音频处理
@property (nonatomic, strong) NSString *mixAudioPath;

@property (nonatomic, strong) AYAudioMixEffect *mixEffect;

// 音频压缩
@property (nonatomic, strong) CompressMedia *audioCompress;

@property (nonatomic, strong) NSString *compressAudioPath;

// 视频处理
@property (nonatomic, copy) NSString *effectVideoPath;

// 视频属性
@property (nonatomic, assign) CGSize naturalSize;

@property (nonatomic, assign) CGFloat radians;

@property (nonatomic, assign) BOOL isPortrait;

// 视频压缩
@property (nonatomic, strong)NSString *compressVideoPath;

// 加特效
@property (nonatomic, strong) MP4ReEncode *reencode;

@property (nonatomic, strong) VideoEffectHandler *videoEffectHandler;

@property (nonatomic, assign) NSUInteger currentEffectType;

@end

@implementation OutputViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _outputView = [[OutputView alloc] init];
    self.outputView.delegate = self;
    
    self.videoEffectHandler = [[VideoEffectHandler alloc] init];
    
    [self.view addSubview:self.outputView];
    [self.view addSubview:self.videoEffectHandler];

    [self.outputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.videoEffectHandler mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(20);
        make.centerY.equalTo(self.view.mas_centerY).offset(20);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(160);
    }];
}

#pragma mark - OutputViewDelegate
- (void)outputViewBack{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)outputViewSaveVideo{
    NSLog(@"保存视频");
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    if (self.musicPath) {
        [self processAudio]; //混音
    }else if (delegate.totalTimeModel && delegate.totalTimeModel.count > 0) {
        [self processVideoWithEffect]; //加特效
    }else {
        [self compressAudioFile];
    }
}

#pragma mark - API
- (void)processAudio{
    NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *cafFileName = [NSString stringWithFormat:@"%@.caf",uuid];
    self.mixAudioPath = [NSTemporaryDirectory() stringByAppendingPathComponent:cafFileName];
    
    NSLog(@"mixAudioPath %@",self.mixAudioPath);
    
    _mixEffect = [AYAudioMixEffect new];
    self.mixEffect.inputMainPath = self.audioPath;
    self.mixEffect.mainVolume = self.audioVolume;
    self.mixEffect.inputDeputyPath = self.musicPath;
    self.mixEffect.deputyVolume = self.musicVolume;
    self.mixEffect.deputyStartTime = self.musicStartTime;
    self.mixEffect.outputPath = self.mixAudioPath;
    
    [self.mixEffect process];
        
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    if (delegate.totalTimeModel && delegate.totalTimeModel.count > 0) {
        [self processVideoWithEffect]; //加特效
    }else {
        [self compressAudioFile];
    }

}

- (void)processVideoWithEffect{
    if (!self.reencode) {
        self.reencode = [[MP4ReEncode alloc] init];
        self.reencode.delegate = self;
    }
    [self.reencode initSetup];
    
    self.reencode.inputURL = [NSURL fileURLWithPath:self.videoPath];
    
    self.effectVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[[[NSUUID UUID] UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] stringByAppendingPathExtension:@"mov"]];
    self.reencode.outputURL = [NSURL fileURLWithPath:self.effectVideoPath];
    
    [self.reencode startReencode];
}

- (void)compressAudioFile{
    NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *m4aFileName = [NSString stringWithFormat:@"%@.mov",uuid];
    _compressAudioPath = [NSTemporaryDirectory() stringByAppendingPathComponent:m4aFileName];
    
    NSString *audioPath = self.mixAudioPath ? self.mixAudioPath : self.audioPath;
    
    _audioCompress = [[CompressMedia alloc] init];
    self.audioCompress.inputURL = [NSURL fileURLWithPath:audioPath];
    self.audioCompress.outputURL = [NSURL fileURLWithPath:self.compressAudioPath];
    
    [self.audioCompress setAudioBitrate:(unsigned int)([self.outputView.audioBitrate integerValue] * 1000)];
    
    [self.audioCompress exportAsynchronouslyWithCompletionHandler:^(BOOL success) {
        if (success) {
            NSLog(@"compress audio path : %@",self.compressAudioPath);

            [self compressVideoFile];

        } else if (self.mediaExporter.status == AVAssetExportSessionStatusFailed){
            NSLog(@"compress audio failed");
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
    }];
}

- (void)compressVideoFile{

    NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *movFileName = [NSString stringWithFormat:@"%@.mov",uuid];
    _compressVideoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:movFileName];
    
    NSString *videoPath = self.effectVideoPath ? self.effectVideoPath : self.videoPath;
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    // 处理视频
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    // 设置最终画面的宽高
    CGAffineTransform preferredTransform = videoAssetTrack.preferredTransform;
    CGSize renderSize = CGSizeZero;
    
    BOOL isVideoPortrait = NO;
    if (preferredTransform.a == 0 && preferredTransform.d == 0 && (preferredTransform.b == 1.0 || preferredTransform.b == -1.0) && (preferredTransform.c == 1.0 || preferredTransform.c == -1.0)) {
        isVideoPortrait = YES;
    }
    
    if (isVideoPortrait) {
        renderSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
    }else {
        renderSize = videoAssetTrack.naturalSize;
    }
    
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    mutableVideoComposition.renderSize = CGSizeMake([self.outputView.resolution integerValue], renderSize.height / renderSize.width  * [self.outputView.resolution integerValue]);
    mutableVideoComposition.frameDuration = videoAssetTrack.minFrameDuration;
    
    // 设置最终画面的缩放
    preferredTransform = CGAffineTransformScale(preferredTransform, [self.outputView.resolution integerValue] /renderSize.width, [self.outputView.resolution integerValue] /renderSize.width);
    
    // 设置视频旋转
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.timeRange = videoAssetTrack.timeRange;
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mutableCompositionVideoTrack];
    [videoLayerInstruction setTransform:preferredTransform atTime:kCMTimeZero];
    
    videoCompositionInstruction.layerInstructions = @[videoLayerInstruction];
    mutableVideoComposition.instructions = @[videoCompositionInstruction];
    
    // 添加水印
    if (self.waterMaskImage) {
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        CALayer *watermarkLayer = [CALayer layer];
        watermarkLayer.contents = (id)self.waterMaskImage.CGImage;
        watermarkLayer.frame = CGRectMake(0, 0, self.waterMaskSize.width / screenSize.width *  mutableVideoComposition.renderSize.width, self.waterMaskSize.height / screenSize.width *  mutableVideoComposition.renderSize.width);
        CALayer *parentLayer = [CALayer layer];
        CALayer *videoLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height);
        videoLayer.frame = CGRectMake(0, 0, mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height);
        [parentLayer addSublayer:videoLayer];
        watermarkLayer.position = CGPointMake(self.waterMaskPosition.x / screenSize.width *  mutableVideoComposition.renderSize.width, mutableVideoComposition.renderSize.height - self.waterMaskPosition.y / screenSize.width *  mutableVideoComposition.renderSize.width);
        [parentLayer addSublayer:watermarkLayer];
        mutableVideoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
    
    _mediaExporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    self.mediaExporter.outputURL = [NSURL fileURLWithPath:self.compressVideoPath];
    self.mediaExporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.mediaExporter.videoComposition = mutableVideoComposition;
    self.mediaExporter.shouldOptimizeForNetworkUse = YES;
    self.mediaExporter.fileLengthLimit = [self.outputView.videoBitrate integerValue] * CMTimeGetSeconds(videoAsset.duration) * 1024 / 8;
    
    [self.mediaExporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.mediaExporter.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"compress video path : %@",self.compressVideoPath);
                
                [self synthesizeMedia];
            } else if (self.mediaExporter.status == AVAssetExportSessionStatusFailed){
                NSLog(@"compress video failed");
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        });
    }];
}

- (void)synthesizeMedia{
    NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *mediaFileName = [NSString stringWithFormat:@"%@.mp4",uuid];
    NSString *mediaPath = [NSTemporaryDirectory() stringByAppendingPathComponent:mediaFileName];
    
    NSString *videoPath = self.compressVideoPath;
    NSString *audioPath = self.compressAudioPath;
    
    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    // 处理视频
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
        
    // 处理音频
    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    AVAsset *audioAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:audioPath]];
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    _mediaExporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetPassthrough];
    self.mediaExporter.outputURL = [NSURL fileURLWithPath:mediaPath];
    self.mediaExporter.outputFileType = AVFileTypeMPEG4;
    self.mediaExporter.shouldOptimizeForNetworkUse = YES;
    
    [self.mediaExporter exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.mediaExporter.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"synthesize media path : %@",mediaPath);
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];

                UISaveVideoAtPathToSavedPhotosAlbum(mediaPath, NULL, NULL, NULL);
                
            } else if (self.mediaExporter.status == AVAssetExportSessionStatusFailed){
                NSLog(@"synthesize media failed");
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
        });
    }];
}

#pragma mark - MP4ReEncodeDelegate
/**
 重编码时的视频参数
 */
- (void)MP4ReEncodeVideoParamWithNaturalSize:(CGSize *)naturalSize preferredTransform:(CGAffineTransform *)preferredTransform{
    
    // 视频原始宽高
    self.naturalSize = *naturalSize;
    
    // 视频显示时需要旋转的弦度
    self.radians = atan2(preferredTransform->b, preferredTransform->a);
    
    // 视频是否垂直
    self.isPortrait = NO;
    if (preferredTransform->a == 0 && preferredTransform->d == 0 && (preferredTransform->b == 1.0 || preferredTransform->b == -1.0) && (preferredTransform->c == 1.0 || preferredTransform->c == -1.0)) {
        self.isPortrait = YES;
    }
}

/**
 重编码时视频图像编辑
 */
- (CMSampleBufferRef)MP4ReEncodeProcessVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    //==========重编码处理 线程==========
    __block CMSampleBufferRef tempSampleBuffer;
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        // 找到离当前播放位置最近的特效
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSUInteger effectType = [delegate effectTypeWithTime:CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sampleBuffer))];
        
        if (effectType != NSUIntegerMax && self.currentEffectType != effectType) {
            self.currentEffectType = effectType;
            [self.videoEffectHandler setEffectType:self.currentEffectType];
        }
        
        tempSampleBuffer = [self.videoEffectHandler process:sampleBuffer naturalSize:self.naturalSize radians:self.radians isPortrait:self.isPortrait];
    });
    
//    CMTime time = CMSampleBufferGetPresentationTimeStamp(tempSampleBuffer);
//    NSLog(@"time : %"PRId64" / %"PRId32, time.value/10, time.timescale/10 );
    //==========重编码处理 线程==========
    return tempSampleBuffer;
}

/**
 重编码完成
 */
- (void) MP4ReEncodeFinish:(bool)success{
    if (success) {
        [self compressAudioFile];
    } else {
        NSLog(@"视频重编码失败");
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}

- (void)dealloc{
    NSLog(@" 方法调用了 %s ", __func__);
}

@end
