//
//  EditViewController.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "EditViewController.h"
#import "EditView.h"
#import "PlayerStateView.h"
#import "EffectTimeModel.h"
#import "OutputViewController.h"
#import "MusicViewController.h"
#import "AppDelegate.h"
#import "EffectViewController.h"

#import <AiyaEffectSDK/AiyaEffectSDK.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>

@interface EditViewController () <EditViewDelegate, PlayerStateViewDelegate>

// UI
@property (nonatomic, strong) EditView *editView;
@property (nonatomic, assign) BOOL isViewAppear;

// 播放器
@property (nonatomic, strong) IJKFFMoviePlayerController *player;
@property (nonatomic, strong) PlayerStateView *playerStateView;
@property (nonatomic, strong) NSTimer *playbackTimeTimer; // TODO 记得关闭

// 录音音频播放器
@property (nonatomic, strong) AVAudioPlayer *recordAudioPlayer;

// 背景音乐音频播放器
@property (nonatomic, strong) AVAudioPlayer *musicAudioPlayer;
@property (nonatomic, strong) NSString *musicPath;
@property (nonatomic, assign) CGFloat musicStartTime;

// 数据
@property (nonatomic, strong) EffectTimeModel *currentTimeModel;
@property (nonatomic, assign) BOOL enableWaterMask;

// 特效
@property (nonatomic, assign) AY_SHORT_VIDEO_EFFECT_TYPE currentEffectType;
@property (nonatomic, strong) AYShortVideoEffectHandler *effectHandler;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];
    
    _editView = [[EditView alloc] init];
    self.editView.delegate = self;
    
    [self.view addSubview:self.editView];
    
    [self.editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    // 初始化播放器
    [self initPlayer];
    
    // 初始化音频播放器
    [self initAudioPlayer];

    // 播放器状态布局
    _playerStateView = [[PlayerStateView alloc] initWithFrame:CGRectZero];
    self.playerStateView.delegate = self;
    
    [self.editView.preview addSubview:self.player.view];
    [self.editView.preview addSubview:self.playerStateView];
    
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.playerStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    // 监听播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinish:) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    //页面状态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterForeground:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // 设置License
    [AYLicenseManager initLicense:@"d64495809bc5419db1a13fa2668a8bc5"];
}

#pragma mark - API

/**
 初始化视频播放器
 */
- (void)initPlayer{
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_SILENT];
    
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setOptionIntValue:1 forKey:@"mediacodec_auto_rotate" ofCategory:kIJKFFOptionCategoryPlayer];
    [options setOptionIntValue:1 forKey:@"mediacodec-handle-resolution-change" ofCategory:kIJKFFOptionCategoryPlayer];
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.videoURL withOptions:options];
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = NO;
    [self.player prepareToPlay];
    
    __weak typeof(self) weakSelf = self;
    ((IJKFFMoviePlayerController *)self.player).renderBlock = ^(GLuint texture, GLint width,GLint height) {
        
        //==========IJKPlayer openGL处理 线程==========
        
        // opengGL函数必须保证在openGL线程中调用
        if (!weakSelf.effectHandler) {
            weakSelf.effectHandler = [[AYShortVideoEffectHandler alloc] init];
        }
        
        if (weakSelf.effectHandler.type != weakSelf.currentEffectType) {
            [weakSelf.effectHandler setType:weakSelf.currentEffectType];
        }
        
        [weakSelf.effectHandler processWithTexture:texture width:width height:height];
        //==========IJKPlayer GL处理 线程==========
    };
}

/**
 初始化音频播放器
 */
- (void)initAudioPlayer{
    NSError *error;
    self.recordAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioURL error:&error];
    
    if (error) {
        NSLog(@"initAudioPlayerError %@",error.localizedDescription);
    }
}

#pragma mark IJKMPMoviePlayerPlaybackDidFinishNotification 播放到了结束位置
- (void)playerDidFinish:(NSNotification *)notification{
    
    // 设置特效
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSUInteger effectType = [delegate effectTypeWithTime:0];
    if (effectType != NSUIntegerMax) {
        self.currentEffectType = effectType;
    }
    
    [self.player setCurrentPlaybackTime:0];
    
    [self.recordAudioPlayer stop];
    [self.recordAudioPlayer setCurrentTime:0];
    
    [self.musicAudioPlayer stop];
    [self.musicAudioPlayer setCurrentTime:self.musicStartTime];
    
    [self.playerStateView setShowStopBt];
}

#pragma mark - Life circle
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.isViewAppear = YES;

    // 播放背景音乐
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.musicPath) {
        if ([delegate.musicPath isEqualToString:self.musicPath]) {
            // 音乐相同, seek到当前的播放位置, 开始播放
            self.musicAudioPlayer.currentTime = self.musicStartTime + self.recordAudioPlayer.currentTime;
            [self.musicAudioPlayer play];
        } else {
            // 音乐不同, seek到当前的播放位置, 开始播放
            [self.musicAudioPlayer stop];
            self.musicAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:delegate.musicPath] error:nil];
            self.musicAudioPlayer.currentTime = self.recordAudioPlayer.currentTime;
            [self.musicAudioPlayer play];
            
            self.musicStartTime = 0;
            self.musicPath = delegate.musicPath;
        }
    } else {
        // 没有音乐
        [self.musicAudioPlayer stop];
        self.musicAudioPlayer  = nil;
        
        self.musicPath = nil;
        self.musicStartTime = 0;
    }
    
    // 播放视频
    [self.player play];
    [self.recordAudioPlayer play];
    
    [self.playerStateView setHiddenStopBt];
    
    // 监听播放进度
    self.playbackTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0/15.0 target:self selector:@selector(updatePlaybackTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.playbackTimeTimer forMode:NSRunLoopCommonModes];
    
    // 关闭滑动返回
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.isViewAppear = NO;

    // 暂停视频
    [self.player pause];
    [self.recordAudioPlayer pause];
    
    [self.playerStateView setShowStopBt];

    // 暂停背景音乐
    [self.musicAudioPlayer pause];
    
    // 关闭监听播放进度
    [self.playbackTimeTimer invalidate];
    self.playbackTimeTimer = nil;
    
    // 打开滑动返回
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)enterForeground:(NSNotification *)notification{
    if (self.isViewAppear) {
        
        // 开始播放
        [self.player play];
        [self.recordAudioPlayer play];
        [self.musicAudioPlayer play];

        // 监听播放进度
        self.playbackTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0/15.0 target:self selector:@selector(updatePlaybackTime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.playbackTimeTimer forMode:NSRunLoopCommonModes];
        
        [self.playerStateView setHiddenStopBt];
    }
}

- (void)enterBackground:(NSNotification *)notification{
    if (self.isViewAppear) {
        
        // 暂停播放
        [self.player pause];
        [self.recordAudioPlayer pause];
        [self.musicAudioPlayer pause];

        // 关闭监听播放进度
        [self.playbackTimeTimer invalidate];
        self.playbackTimeTimer = nil;
        
        [self.playerStateView setShowStopBt];
    }
}

#pragma mark - EditViewDelegate
- (void)editViewBack{
    // Timer要手动释放
    [self.playbackTimeTimer invalidate];
    
    // ijkplayer要手动释放
    [self.player stop];
    [self.player shutdown];
    [self.player.view removeFromSuperview];
    self.player = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    // 关闭特效
    self.effectHandler = nil;
    
    // 释放数据
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.musicName = nil;
    delegate.musicPath = nil;
    delegate.totalTimeModel = nil;
    
    // 关闭页面
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editViewNext{
    OutputViewController *outputVC = [[OutputViewController alloc] init];
    outputVC.videoPath = self.videoURL.path;
    
    if (self.enableWaterMask) {
        outputVC.waterMaskImage = [UIImage imageNamed:@"icon"];
        outputVC.waterMaskSize = CGSizeMake(50, 50);
        outputVC.waterMaskPosition = CGPointMake(55, 55);
    }

    outputVC.audioPath = self.audioURL.path;

    outputVC.audioVolume = self.recordAudioPlayer.volume;
    
    if (self.musicPath) {
        outputVC.musicPath = self.musicPath;
        outputVC.musicVolume = self.musicAudioPlayer.volume;
        outputVC.musicStartTime = self.musicStartTime;
    }
    [self.navigationController pushViewController:outputVC animated:YES];
}

- (void)editViewOriginalAudioMute:(BOOL)mute{
    if (mute) {
        self.recordAudioPlayer.volume = 0;
    } else {
        self.recordAudioPlayer.volume = 1;
    }
}

- (void)editViewSelectMusic{
    MusicViewController *musicVC = [[MusicViewController alloc] init];
    [self.navigationController pushViewController:musicVC animated:YES];
}

- (void)editViewCutMusicClick{
    if (self.musicPath) {
        // 显示UI
        [self.editView setMusicStartTime:self.musicStartTime];
        [self.editView setMusicPath:self.musicPath];
        [self.editView setAudioDuration:CMTimeGetSeconds([AVAsset assetWithURL:self.audioURL].duration)];
        [self.editView showCutMusicView];

        // 关闭视频播放
        [self.player pause];
        [self.recordAudioPlayer stop];
        
        [self.playerStateView setHidden:YES];
        
        // 打开音乐播放
        [self.musicAudioPlayer setCurrentTime:self.musicStartTime];
        [self.musicAudioPlayer play];
    } else {
        NSLog(@"请先选择一个音乐");
    }
}

- (void)editViewCutMusic:(CGFloat)startTime{
    self.musicStartTime = startTime;
    [self.musicAudioPlayer setCurrentTime:self.musicStartTime];
    
    if (![self.musicAudioPlayer isPlaying]) {
        [self.musicAudioPlayer play];
    }
}

- (void)editViewCutMusicFinish{
    // 关闭UI
    [self.editView hideCutMusicView];

    // 重新开始当前页面的播放
    [self.player setCurrentPlaybackTime:0];
    [self.recordAudioPlayer setCurrentTime:0];
    [self.musicAudioPlayer setCurrentTime:self.musicStartTime];
    
    [self.player play];
    [self.recordAudioPlayer play];
    [self.musicAudioPlayer play];
    
    [self.playerStateView setHidden:NO];
    [self.playerStateView setHiddenStopBt];
}

- (void)editViewVolumeClick{
    //显示UI
    [self.editView setRecordAudioVolume:self.recordAudioPlayer.volume];
    [self.editView setMusicVolume:self.musicAudioPlayer ? self.musicAudioPlayer.volume : 0];
    [self.editView showMixVolume];
    
    // 关闭视频播放
    [self.player pause];
    [self.playerStateView setHidden:YES];

    // 打开音乐循环播放
    [self.recordAudioPlayer setNumberOfLoops:-1];
    [self.recordAudioPlayer play];
    [self.musicAudioPlayer setNumberOfLoops:-1];
    [self.musicAudioPlayer setCurrentTime:self.musicStartTime];
    [self.musicAudioPlayer play];
}

- (void)editViewAudioVolume:(CGFloat)volume musicVolume:(CGFloat)musicVolume{
    [self.recordAudioPlayer setVolume:volume];
    [self.musicAudioPlayer setVolume:musicVolume];
}

- (void)editViewVolumeFinish{
    // 关闭UI
    [self.editView hideMixVolume];
    
    // 重新开始当前页面的播放
    [self.player setCurrentPlaybackTime:0];
    [self.recordAudioPlayer setNumberOfLoops:0];
    [self.recordAudioPlayer setCurrentTime:0];
    [self.musicAudioPlayer setNumberOfLoops:0];
    [self.musicAudioPlayer setCurrentTime:self.musicStartTime];
    
    [self.player play];
    [self.recordAudioPlayer play];
    [self.musicAudioPlayer play];
    
    [self.playerStateView setHidden:NO];
    [self.playerStateView setHiddenStopBt];
}

- (void)editViewAddEffect{
    EffectViewController *effectVC = [[EffectViewController alloc] init];
    effectVC.videoURL = self.videoURL;
    effectVC.audioURL = self.audioURL;
    
    [self.navigationController pushViewController:effectVC animated:YES];
 }

- (void)editViewWaterMask:(BOOL)show{
    self.enableWaterMask = show;
}

#pragma mark - PlayerStateViewDelegate
- (void)playerStateViewOnStopBtClick{
    if (self.player.isPlaying) {
        // 暂停当前页面的播放
        [self.player pause];
        [self.recordAudioPlayer pause];
        [self.musicAudioPlayer pause];
        
        [self.playerStateView setShowStopBt];
    }else {
        // 重新开始当前页面的播放
        [self.player play];
        [self.recordAudioPlayer play];
        [self.musicAudioPlayer play];
        
        [self.playerStateView setHiddenStopBt];
    }
}

#pragma mark - timer
- (void)updatePlaybackTime{
    if (self.player.isPlaying) {
        
        // 找到离当前播放位置最近的特效
        CGFloat currentTime = self.recordAudioPlayer.currentTime;
        
        // 设置特效
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSUInteger effectType = [delegate effectTypeWithTime:currentTime];
        if (effectType != NSUIntegerMax) {
            self.currentEffectType = effectType;
        }
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@" 方法调用了 %s ", __func__);
}

@end
