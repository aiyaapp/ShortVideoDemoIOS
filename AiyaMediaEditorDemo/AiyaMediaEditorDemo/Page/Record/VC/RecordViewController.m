//
//  RecordViewController.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "RecordViewController.h"
#import "RecordView.h"
#import "Camera.h"
#import "CameraDataProcess.h"
#import "MediaWriter.h"
#import "Preview.h"
#import "EditViewController.h"
#import "MediaItemModel.h"

#import "EffectViewController.h"

#import <Masonry/Masonry.h>
#import <AiyaMediaEditor/AiyaMediaEditor.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <AiyaEffectSDK/AiyaEffectSDK.h>

// 最长录制时间
static const CGFloat longestVideoSeconds = 30;

@interface RecordViewController () <CameraDelegate, CameraDataProcessDelegate, RecordViewDelegate>

// 状态
@property (nonatomic, assign, getter=isViewAppear) BOOL viewAppear;
@property (atomic, assign, getter=isWriteData) BOOL writeData;
@property (atomic, assign, getter=isStopOpenGL) BOOL stopOpenGL;

// 录制视频
@property (nonatomic, strong) Camera *camera;
@property (nonatomic, strong) CameraDataProcess *dataProcess;
@property (nonatomic, strong) Preview *preview;
@property (nonatomic, strong) MediaWriter *writer;

// 特效
@property (nonatomic, strong) AYEffectHandler *effectHandler;

// 页面
@property (nonatomic, strong) RecordView *recordView;
@property (nonatomic, strong) CALayer *focusBoxLayer;
@property (nonatomic, strong) CAAnimation *focusBoxAnimation;

@property (nonatomic, strong) UIButton *effectBt;

// 数据
@property (nonatomic, strong) NSMutableArray<MediaItemModel *> *mediaItemArr;
@property (nonatomic, strong) MediaItemModel *recordingMediaItem;
@property (nonatomic, strong) NSURL *synthesizeVideoURL;
@property (nonatomic, strong) NSURL *synthesizeAudioURL;

// 音效器
@property (nonatomic, strong) AYAudioTempoEffect *audioTempoEffect;

// 导出
@property (nonatomic, strong) AVAssetExportSession *videoExporter;
@property (nonatomic, strong) AVAssetExportSession *audioExporter;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _recordView = [[RecordView alloc] init];
    self.recordView.delegate = self;
    
    // 设置相机预览
    self.preview = [[Preview alloc] initWithFrame:CGRectZero];
    
    [self.recordView.cameraPreview addSubview:self.preview];
    [self.view addSubview:self.recordView];
    
    [self.recordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    // 添加点按手势，点按时聚焦
    UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapScreen:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.recordView.cameraPreview addGestureRecognizer:tapGesture];
    
    //录制视频
    self.writer = [[MediaWriter alloc]init];
    
    //设置录制出来的视频的分辩率
    self.writer.videoWidth = [self.resolution integerValue];
    
    //数据处理
    self.dataProcess = [[CameraDataProcess alloc] init];
    self.dataProcess.delegate = self;
    self.dataProcess.mirror = YES;
    
    //相机
    self.camera = [[Camera alloc] init];
    self.camera.delegate = self;
    
    //设置相机状态
    [self.camera setRate:60];
    
    //页面状态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 初始数据
    [self initData];
    
    // 设置License
    [AYLicenseManager initLicense:@"d64495809bc5419db1a13fa2668a8bc5"];
}

- (void)initData{
    self.recordingMediaItem = [MediaItemModel new];
    self.mediaItemArr = [NSMutableArray array];
    
    self.recordView.progressView.recordingMediaItem = self.recordingMediaItem;
    self.recordView.progressView.mediaItemArr = self.mediaItemArr;
    self.recordView.progressView.longestVideoSeconds = longestVideoSeconds;
}

#pragma mark - viewControllerLifeCycle
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.viewAppear= YES;

    // 修改状态
    self.stopOpenGL = NO;
    self.preview.renderSuspended = NO;
    self.dataProcess.renderSuspended = NO;
    
    // 打开相机
    [self.camera startCapture];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    self.viewAppear= NO;

    // 修改状态
    self.stopOpenGL = YES;
    self.preview.renderSuspended = YES;
    self.dataProcess.renderSuspended = YES;

    // 关闭相机
    [self.camera stopCapture];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)enterForeground:(NSNotification *)notifi{
    if ([self isViewAppear]) {

        // 修改状态
        self.stopOpenGL = NO;
        self.preview.renderSuspended = NO;
        self.dataProcess.renderSuspended = NO;

        // 打开相机
        [self.camera startCapture];
        
        [UIApplication sharedApplication].idleTimerDisabled = YES;
    }
}

- (void)enterBackground:(NSNotification *)notifi{
    if ([self isViewAppear]) {

        // 修改状态
        self.stopOpenGL = YES;
        self.preview.renderSuspended = YES;
        self.dataProcess.renderSuspended = YES;

        // 取消录制
        [self cancelRecordVideo];

        // 关闭相机
        [self.camera stopCapture];

        [UIApplication sharedApplication].idleTimerDisabled = NO;
    }
}

#pragma mark - RecordViewDelegate
- (void)recordViewBack{
    NSLog(@"返回");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recordViewSwitchCamera{
    NSLog(@"切换相机");
    if (self.camera.cameraPosition == AVCaptureDevicePositionBack) {
        [self.camera setCameraPosition:AVCaptureDevicePositionFront];
        [self.dataProcess setMirror:YES];
    } else {
        [self.camera setCameraPosition:AVCaptureDevicePositionBack];
        [self.dataProcess setMirror:NO];
    }
}

- (void)recordViewNext{
    if (self.mediaItemArr.count == 0) {
        NSLog(@"请录制一段视频");
        return;
    }
    
    if (![self.writer isWriteFinish]) {
        NSLog(@"请等待录制完成");
        return;
    }
    
    NSLog(@"下一步");

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [self synthesizeVideo];
    [self synthesizeAudio];
}

- (void)recordViewBeauty:(BOOL)open{
    if (open) {
        NSLog(@"打开美颜");
        [self.effectHandler setSmooth:1];
        [self.effectHandler setWhiten:0.2];
        [self.effectHandler setSaturation:0.2];
    }else {
        NSLog(@"关闭美颜");
        [self.effectHandler setSmooth:0];
        [self.effectHandler setWhiten:0];
        [self.effectHandler setSaturation:0];
    }
}

- (void)recordViewStyle:(StyleModel *)model{
    NSLog(@"点击了滤镜 %@",model.text);
    
    [self.effectHandler setStyle:[UIImage imageWithContentsOfFile:model.path]];
    [self.effectHandler setIntensityOfStyle:0.8];
}

- (void)recordViewFaceEffect:(FaceEffectModel *)model{
    NSLog(@"点击了特效 %@",model.text);
    
    [self.effectHandler setEffectPath:model.path];
}

- (void)recordViewStartRecord{
    NSLog(@"开始录制");
    [self startRecordVideo];
}

- (void)recordViewStopRecord{
    NSLog(@"停止录制");
    [self finishRecordVideo];
}

- (void)recordViewDelete{
    NSLog(@"删除最后一段视频");
    
    // 删除音视频文件
    MediaItemModel *modelItemModel = [self.mediaItemArr lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:modelItemModel.videoPath]) {
        [fileManager removeItemAtPath:modelItemModel.videoPath error:nil];
    }
    if ([fileManager fileExistsAtPath:modelItemModel.audioPath]) {
        [fileManager removeItemAtPath:modelItemModel.audioPath error:nil];
    }
    
    [self.mediaItemArr removeLastObject];
    [self.recordView.progressView setNeedsDisplay];
}

#pragma mar - Tap Screen
-(void)tapScreen:(UITapGestureRecognizer *)tapGesture{
    CGPoint point= [tapGesture locationInView:self.preview];
    
    CGPoint pointOfInterest;
    if (self.dataProcess.mirror) { // 相机的输出画面是横的. 屏幕的右上角在相机中是左上, 屏幕的左下角在相机中是右下, 前置画面做了镜像
        pointOfInterest = CGPointMake(point.y / self.preview.bounds.size.height, point.x / self.preview.bounds.size.width);
    } else {
        pointOfInterest = CGPointMake(point.y / self.preview.bounds.size.height, 1.0f - point.x / self.preview.bounds.size.width);
    }
    
    NSLog(@"设置相机焦点 x:%f y:%f",pointOfInterest.x, pointOfInterest.y);
    
    [self.camera focusAtPoint:pointOfInterest];
    [self showFocusBox:point];
}

- (void)showFocusBox:(CGPoint)point{
    if(!self.focusBoxLayer) {
        CALayer *focusBoxLayer = [[CALayer alloc] init];
        focusBoxLayer.cornerRadius = 3.0f;
        focusBoxLayer.bounds = CGRectMake(0.0f, 0.0f, 70, 70);
        focusBoxLayer.borderWidth = 1.0f;
        focusBoxLayer.borderColor = [[UIColor yellowColor] CGColor];
        focusBoxLayer.opacity = 0.0f;
        [self.preview.layer addSublayer:focusBoxLayer];
        self.focusBoxLayer = focusBoxLayer;
    }
    
    if(!self.focusBoxAnimation) {
        CABasicAnimation *focusBoxAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        focusBoxAnimation.duration = 1;
        focusBoxAnimation.autoreverses = NO;
        focusBoxAnimation.repeatCount = 0.0;
        focusBoxAnimation.fromValue = [NSNumber numberWithFloat:1.0];
        focusBoxAnimation.toValue = [NSNumber numberWithFloat:0.0];
        self.focusBoxAnimation = focusBoxAnimation;
    }
    
    if(self.focusBoxLayer) {
        [self.focusBoxLayer removeAllAnimations];
        
        [CATransaction begin];
        [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
        self.focusBoxLayer.position = point;
        [CATransaction commit];
    }
    
    if(self.focusBoxAnimation) {
        [self.focusBoxLayer addAnimation:self.focusBoxAnimation forKey:@"animateOpacity"];
    }
}

#pragma mark - CameraDelegate
/**
 相机回调的视频数据
 */
- (void)cameraVideoOutput:(CMSampleBufferRef)sampleBuffer{
    
    //========== 当前为相机视频数据传输 线程==========//
    
    if (self.stopOpenGL) {
        NSLog(@"页面已经进入后台, OPENGL 停止 1");
        return;
    }

    // 处理数据, 耗时操作
    CMSampleBufferRef bgraSampleBuffer = [self.dataProcess process:sampleBuffer];
    
    // 因为[dataProcess process:] 是耗时操作, 所以接下来要再次判断是否还在前台
    if (self.stopOpenGL) {
        if (bgraSampleBuffer){
            CMSampleBufferInvalidate(bgraSampleBuffer);
            CFRelease(bgraSampleBuffer);
            bgraSampleBuffer = NULL;
        }
        NSLog(@"页面已经进入后台, OPENGL 停止 2");
        return;
    }
    
    // 预览
    [self.preview render:CMSampleBufferGetImageBuffer(bgraSampleBuffer)];
    
    // 写数据到Mp4文件
    if (self.writeData) {

        CGFloat time = CMTimeGetSeconds(self.writer.lastFramePresentationTimeStamp);

        dispatch_sync(dispatch_get_main_queue(), ^{
            self.recordingMediaItem.videoSeconds = time;

            [self.recordView.progressView setNeedsDisplay];
        });
        
        CGFloat recordedTime = 0;
        for (MediaItemModel *model in self.mediaItemArr) {
            recordedTime += model.videoSeconds;
        }

        if (recordedTime + time >= longestVideoSeconds){ // 超过了写入的时长, 强制完成
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.recordView clickRecordBt];
            });
        }else {
            if (bgraSampleBuffer) {
                [self.writer writeVideoPixelBuffer:CMSampleBufferGetImageBuffer(bgraSampleBuffer) time:CMSampleBufferGetPresentationTimeStamp(bgraSampleBuffer)];
            }
        }
    }
    
    // 释放资源
    if (bgraSampleBuffer){
        CMSampleBufferInvalidate(bgraSampleBuffer);
        CFRelease(bgraSampleBuffer);
        bgraSampleBuffer = NULL;
    }
    
    //========== 当前为相机视频数据传输 线程==========//
}

/**
 相机回调的音频数据
 */
- (void)cameraAudioOutput:(CMSampleBufferRef)sampleBuffer{
    
    //========== 当前为相机音频数据传输 线程==========//
    
    //写数据到Mp4文件
    if (self.writeData) {
        [self.writer writeAudioSampleBuffer:sampleBuffer];
    }
    
    //========== 当前为相机音频数据传输 线程==========//
}

#pragma mark - CameraDataProcessDelegate
/**
 处理回调的纹理数据
 
 @param texture 纹理数据
 */
- (GLuint)cameraDataProcessWithTexture:(GLuint)texture width:(GLuint)width height:(GLuint)height{
    
    //========== 当前为相机视频数据传输 线程==========//
    if (!self.effectHandler && !self.stopOpenGL) {
        self.effectHandler = [[AYEffectHandler alloc] init];
        self.effectHandler.verticalFlip = YES;
    }

    [self.effectHandler processWithTexture:texture width:width height:height];

    return texture;
    
    //========== 当前为相机视频数据传输 线程==========//
}

#pragma mark - recordvideo controller
- (void)startRecordVideo{
    NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *videoFileName = [NSString stringWithFormat:@"%@.m4v",uuid];
    NSString *audioFileName = [NSString stringWithFormat:@"%@.caf",uuid];
    NSString *audioTempoFileName = [NSString stringWithFormat:@"%@_tempo.caf",uuid];
    
    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoFileName];
    NSString *audioPath = [NSTemporaryDirectory() stringByAppendingPathComponent:audioFileName];
    NSString *audioTempoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:audioTempoFileName];
    
    if (!self.audioTempoEffect) {
        self.audioTempoEffect = [AYAudioTempoEffect new];
    }
    self.audioTempoEffect.inputPath = audioPath;
    self.audioTempoEffect.outputPath = audioTempoPath;

    self.writer.outputVideoURL = [[NSURL alloc]initFileURLWithPath:videoPath];
    self.writer.outputAudioURL = [[NSURL alloc]initFileURLWithPath:audioPath];
    
    self.recordingMediaItem.speed = CMTimeMake(1, 1);
    if ([@"极慢" isEqualToString:self.recordView.speedRadioBt.selectedText]) {
        self.recordingMediaItem.speed = CMTimeMake(4, 10);
    } else if ([@"慢" isEqualToString:self.recordView.speedRadioBt.selectedText]) {
        self.recordingMediaItem.speed = CMTimeMake(8, 10);
    } else if ([@"标准" isEqualToString:self.recordView.speedRadioBt.selectedText]) {
        self.recordingMediaItem.speed = CMTimeMake(10, 10);
    } else if ([@"快" isEqualToString:self.recordView.speedRadioBt.selectedText]) {
        self.recordingMediaItem.speed = CMTimeMake(12, 10);
    } else if ([@"极快" isEqualToString:self.recordView.speedRadioBt.selectedText]) {
        self.recordingMediaItem.speed = CMTimeMake(14, 10);
    }
    
    self.writer.videoSpeed = self.recordingMediaItem.speed;
    self.audioTempoEffect.tempo = CMTimeGetSeconds(self.recordingMediaItem.speed);
    
    self.writeData = YES;
    
    self.recordingMediaItem.videoPath = videoPath;
    self.recordingMediaItem.videoSeconds = 0;
    self.recordingMediaItem.audioPath = audioPath;
    self.recordingMediaItem.audioTempoPath = audioTempoPath;
    
    NSLog(@"录制的视频保存地址 temp/%@",videoFileName);
}

- (void)finishRecordVideo{
    if (self.writeData) {
        self.writeData = NO;
        
        __weak typeof(self) ws = self;
        [self.writer finishWritingWithCompletionHandler:^{
            __strong typeof(ws) strongSelf = ws;
            //========== 当前为视频录制 线程==========//
            
            NSLog(@"视频录制完成");
            
            CGFloat time = CMTimeGetSeconds(strongSelf.writer.lastFramePresentationTimeStamp);
            if (time < 1) {
                NSLog(@"视频录制时长小于一秒");
            }else {
                // 处理音频节奏
                if (CMTimeGetSeconds(strongSelf.recordingMediaItem.speed) != 1) {
                    [self.audioTempoEffect process];
                    self.audioTempoEffect = nil;
                } else {
                    strongSelf.recordingMediaItem.audioTempoPath = strongSelf.recordingMediaItem.audioPath;
                }
                
                MediaItemModel *model = [MediaItemModel new];
                model.videoPath = strongSelf.recordingMediaItem.videoPath;
                model.videoSeconds = time;
                model.audioPath = strongSelf.recordingMediaItem.audioPath;
                model.audioTempoPath = strongSelf.recordingMediaItem.audioTempoPath;
                model.speed = strongSelf.recordingMediaItem.speed;
                [strongSelf.mediaItemArr addObject:model];
            }
            
            // 更新布局
            strongSelf.recordingMediaItem.videoSeconds = 0;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.recordView.progressView setNeedsDisplay];
            });
            
            //========== 当前为视频录制 线程==========//
        }];
    }
}

- (void)cancelRecordVideo{
    if (self.writeData) {
        self.writeData = NO;
        
        NSLog(@"视频录制取消");
        
        [self.writer cancelWriting];
        
        // 更新布局
        self.recordingMediaItem.videoSeconds = 0;
        [self.recordView.progressView setNeedsDisplay];
        [self.recordView.recordBt setSelected:NO];
    }
}

#pragma mark - synthesize media
/**
 合成视频
 */
- (void)synthesizeVideo{
    self.synthesizeVideoURL = nil;
    
    NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *videoFileName = [NSString stringWithFormat:@"%@.mov",uuid];
    NSString *videoPath = [NSTemporaryDirectory() stringByAppendingPathComponent:videoFileName];

    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    // 创建总的视频轨道
    AVMutableCompositionTrack *mutableCompositionVideoTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime allDuration = kCMTimeZero;
    CGSize renderSize = CGSizeZero;
    CGAffineTransform preferredTransform = CGAffineTransformIdentity;
    
    for (MediaItemModel *mediaModel in self.mediaItemArr) {
        
        // 添加视频轨道
        AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:mediaModel.videoPath]];
        AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        [mutableCompositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration) ofTrack:videoAssetTrack atTime:allDuration error:nil];
                
        // 设置最终画面的宽高
        BOOL isVideoPortrait = NO;
        if (CGSizeEqualToSize(renderSize, CGSizeZero)) {
            CGAffineTransform firstTransform = videoAssetTrack.preferredTransform;

            if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {
                isVideoPortrait = YES;
            }
        
            if (isVideoPortrait) {
                renderSize = CGSizeMake(videoAssetTrack.naturalSize.height, videoAssetTrack.naturalSize.width);
            }else {
                renderSize = videoAssetTrack.naturalSize;
            }
            
            preferredTransform = videoAssetTrack.preferredTransform;
        }
        
        allDuration = CMTimeAdd(allDuration, videoAssetTrack.timeRange.duration);
    }
    
    // 创建总的视频成份, 用来设置轨道的参数
    AVMutableVideoComposition *mutableVideoComposition = [AVMutableVideoComposition videoComposition];
    
    // 设置视频旋转
    AVMutableVideoCompositionInstruction *videoCompositionInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    videoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, allDuration);
    
    AVMutableVideoCompositionLayerInstruction *videoLayerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:mutableCompositionVideoTrack];
    [videoLayerInstruction setTransform:preferredTransform atTime:kCMTimeZero];
    
    videoCompositionInstruction.layerInstructions = @[videoLayerInstruction];
    mutableVideoComposition.instructions = @[videoCompositionInstruction];

    // 设置视频宽高
    mutableVideoComposition.renderSize = renderSize;
    
    // 设置视频帧率
    mutableVideoComposition.frameDuration = CMTimeMake(1, (int32_t)[self.frameRate integerValue]);
    
    _videoExporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetHighestQuality];
    self.videoExporter.outputURL = [NSURL fileURLWithPath:videoPath];
    self.videoExporter.outputFileType = AVFileTypeQuickTimeMovie;
    self.videoExporter.videoComposition = mutableVideoComposition;
    self.videoExporter.shouldOptimizeForNetworkUse = YES;
    self.videoExporter.fileLengthLimit = [self.videoBitrate integerValue] * CMTimeGetSeconds(allDuration) * 1024 / 8;

    [self.videoExporter exportAsynchronouslyWithCompletionHandler:^{
        //========== 当前为视频合成 线程==========//

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.videoExporter.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"synthesize video path : %@",videoPath);
                self.synthesizeVideoURL = [NSURL fileURLWithPath:videoPath];
                
                [self enterEditVC];
            } else if (self.videoExporter.status == AVAssetExportSessionStatusFailed){
                NSLog(@"synthesize video failed %@",self.videoExporter.error);
            }
        });
        //========== 当前为视频合成 线程==========//
    }];
}

/**
 合成音频
 */
- (void)synthesizeAudio{
    self.synthesizeAudioURL = nil;

    NSString *uuid = [[NSUUID UUID].UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSString *audioFileName = [NSString stringWithFormat:@"%@.caf",uuid];
    NSString *audioPath = [NSTemporaryDirectory() stringByAppendingPathComponent:audioFileName];

    AVMutableComposition *mutableComposition = [AVMutableComposition composition];
    
    AVMutableCompositionTrack *mutableCompositionAudioTrack = [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CMTime allDuration = kCMTimeZero;
    
    for (MediaItemModel *mediaModel in self.mediaItemArr) {
        AVAsset *videoAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:mediaModel.videoPath]];
        AVAsset *audioAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:mediaModel.audioTempoPath]];
        
        AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
        AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];

        [mutableCompositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero,videoAssetTrack.timeRange.duration) ofTrack:audioAssetTrack atTime:allDuration error:nil];
        
        allDuration = CMTimeAdd(allDuration, videoAssetTrack.timeRange.duration);
    }
    
    _audioExporter = [[AVAssetExportSession alloc] initWithAsset:mutableComposition presetName:AVAssetExportPresetPassthrough];
    self.audioExporter.outputURL = [NSURL fileURLWithPath:audioPath];
    self.audioExporter.outputFileType = AVFileTypeCoreAudioFormat;
    self.audioExporter.shouldOptimizeForNetworkUse = YES;

    [self.audioExporter exportAsynchronouslyWithCompletionHandler:^{
        //========== 当前为音频合成 线程==========//

        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.audioExporter.status == AVAssetExportSessionStatusCompleted) {
                NSLog(@"synthesize audio path : %@",audioPath);
                self.synthesizeAudioURL = [NSURL fileURLWithPath:audioPath];
                
                [self enterEditVC];
            } else if (self.audioExporter.status == AVAssetExportSessionStatusFailed){
                NSLog(@"synthesize audio failed");
            }
        });
        //========== 当前为音频合成 线程==========//
    }];
}

- (void)enterEditVC{
    if (self.synthesizeAudioURL && self.synthesizeVideoURL) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];

        [self.recordView deselectBeautyBt];
        
        self.stopOpenGL = YES;
        self.dataProcess.renderSuspended = YES;
        self.preview.renderSuspended = YES;

        [self.dataProcess releaseGLResources];
        [self.preview releaseGLResources];
        self.effectHandler = nil;

        EditViewController *editVC = [[EditViewController alloc] init];
        editVC.audioURL = self.synthesizeAudioURL;
        editVC.videoURL = self.synthesizeVideoURL;
        [self.navigationController pushViewController:editVC animated:YES];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@" 方法调用了 %s ", __func__);
}

@end
