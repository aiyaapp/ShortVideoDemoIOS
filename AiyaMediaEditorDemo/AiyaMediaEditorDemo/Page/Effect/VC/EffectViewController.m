//
//  EffectViewController.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/3.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "EffectViewController.h"
#import "EffectView.h"
#import "PlayerStateView.h"
#import "EffectTimeModel.h"
#import "AppDelegate.h"
#import "VideoEffectData.h"

#import <AiyaEffectSDK/AiyaEffectSDK.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import <Masonry/Masonry.h>

@interface EffectViewController () <EffectViewDelegate, PlayerStateViewDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) EffectView *effectView;

@property (nonatomic, strong) IJKFFMoviePlayerController *player;

@property (nonatomic, strong) PlayerStateView *playerStateView;

@property (nonatomic, strong) NSTimer *playbackTimeTimer;

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

// 数据
@property (nonatomic, weak) NSMutableArray<EffectTimeModel *> *totalTimeModel;
@property (nonatomic, strong) EffectTimeModel *currentTimeModel;

@property (nonatomic, assign) BOOL playEnd;

// 特效
@property (nonatomic, assign) AY_SHORT_VIDEO_EFFECT_TYPE currentEffectType;
@property (nonatomic, strong) AYShortVideoEffectHandler *effectHandler;

@end

@implementation EffectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _effectView = [[EffectView alloc] init];
    self.effectView.videoURL = self.videoURL;
    self.effectView.audioURL = self.audioURL;
    self.effectView.delegate = self;
    
    [self.view addSubview:self.effectView];
    
    [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    // 初始化播放器
    [self initPlayer];
    
    // 布局
    _playerStateView = [[PlayerStateView alloc] initWithFrame:CGRectZero];
    self.playerStateView.delegate = self;
    
    [self.effectView.preview addSubview:self.player.view];
    [self.effectView.preview addSubview:self.playerStateView];
    
    [self.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.playerStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    // 设置数据
    [self initData];
    
    [AYLicenseManager initLicense:@"d64495809bc5419db1a13fa2668a8bc5"];
}

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

        // effectHandler 中的所有函数必须保证在同时一个线程中调用
        if (!weakSelf.effectHandler) {
            weakSelf.effectHandler = [[AYShortVideoEffectHandler alloc] init];
        }
        
        if (weakSelf.effectHandler.type != weakSelf.currentEffectType) {
            [weakSelf.effectHandler setType:weakSelf.currentEffectType];
        }
        
        [weakSelf.effectHandler processWithTexture:texture width:width height:height];
        //==========IJKPlayer openGL处理 线程==========
    };
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioURL error:nil];
    self.audioPlayer.volume = 0;
    self.audioPlayer.delegate = self;
}

/**
 设置数据
 */
- (void)initData{
    NSMutableArray *effectCellModels = [NSMutableArray arrayWithCapacity:10];
    
    NSArray<VideoEffectModel *> *data = [VideoEffectData data];
    
    for (int x = 0; x < data.count; x++) {
        EffectCellModel *model = [EffectCellModel new];
        model.model = data[x];
        switch (x % 3) {
            case 0:
                model.effectColor = [UIColor colorWithRed:1 green:0 blue:0 alpha:1];
                break;
            case 1:
                model.effectColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:1];
                break;
            case 2:
                model.effectColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
                break;
            default:
                break;
        }
        [effectCellModels addObject:model];
    }
    
    [self.effectView setSelectorDataArr:effectCellModels];
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!delegate.totalTimeModel) {
        delegate.totalTimeModel = [NSMutableArray array];
    }
    
    self.totalTimeModel = delegate.totalTimeModel;
    [self.effectView setEffectTimeArr:self.totalTimeModel];

}

#pragma mark - Life circle
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 监听播放进度
    self.playbackTimeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0/15.0 target:self selector:@selector(updatePlaybackTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.playbackTimeTimer forMode:NSRunLoopCommonModes];
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [self.playbackTimeTimer invalidate];
    self.playbackTimeTimer = nil;
    
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

#pragma mark - EffectViewDelegate
-(void)effectViewBack{
    [self.playbackTimeTimer invalidate];
    [self.player stop];
    [self.player shutdown];
    [self.player.view removeFromSuperview];
    self.player = nil;
    
    self.audioPlayer = nil;
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)effectViewUndo{
    [self.totalTimeModel removeLastObject];
}

- (void)effectViewSeekTo:(CGFloat)progress{
    if (self.player.isPlaying) {
        [self.player pause];
        [self.audioPlayer pause];
        
        [self.playerStateView setShowStopBt];
    }
    
    self.currentEffectType = 0;
    
    [self.player setCurrentPlaybackTime:progress * self.player.duration];
    [self.audioPlayer setCurrentTime:progress * self.audioPlayer.duration];
}

-(void)effectViewTouchDownModel:(EffectCellModel *)model{
    self.currentTimeModel = [EffectTimeModel new];
    self.currentTimeModel.startTime = self.audioPlayer.currentTime;
    self.currentTimeModel.effectColor = model.effectColor;
    self.currentTimeModel.identification = model.model.effectType;
    
    [self.totalTimeModel addObject:self.currentTimeModel];

    if (!self.player.isPlaying) {
        [self.player play];
        [self.audioPlayer play];
        
        [self.playerStateView setHiddenStopBt];
    }
    
    self.playEnd = NO;
}

-(void)effectViewTouchUp{
    if (self.playEnd) {
        self.currentTimeModel.duration = self.audioPlayer.duration - self.currentTimeModel.startTime;
    }else {
        self.currentTimeModel.duration = self.audioPlayer.currentTime - self.currentTimeModel.startTime;
    }
    // 计算当前特效数据的结果, 用于加视频特效
    [self calculateEffectResult];
    
    self.currentTimeModel = nil;

    if (self.player.isPlaying) {
        [self.player pause];
        [self.audioPlayer pause];
        
        [self.playerStateView setShowStopBt];
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self.playerStateView setShowStopBt];
    
    self.playEnd = YES;
}

#pragma mark - PlayerStateViewDelegate
- (void)playerStateViewOnStopBtClick{
    if (self.player.isPlaying) {
        [self.player pause];
        [self.audioPlayer pause];
        
        [self.playerStateView setShowStopBt];
    }else {
        [self.player play];
        [self.audioPlayer play];
        
        [self.playerStateView setHiddenStopBt];
    }
}

#pragma mark - timer
- (void)updatePlaybackTime{
    
    [self.effectView setProgress:self.audioPlayer.currentTime / self.audioPlayer.duration];
    if (self.currentTimeModel) {
        CGFloat duration = self.audioPlayer.currentTime - self.currentTimeModel.startTime;
        if (duration > 0) {
            self.currentTimeModel.duration = duration;
        }else if(self.playEnd){
            self.currentTimeModel.duration = self.audioPlayer.duration - self.currentTimeModel.startTime;
        }
        self.currentEffectType = self.currentTimeModel.identification;
    } else {
        if (self.player.isPlaying) {
            EffectTimeModel *timeModel = [self.totalTimeModel lastObject];
            CGFloat currentTime = self.audioPlayer.currentTime;
            NSArray *effectIndexResult = timeModel.effectIndexResult;
            
            // 找到离当前播放位置最近的特效
            EffectIndexModel *lastModel;
            for (EffectIndexModel *indexModel in effectIndexResult) {
                if (!lastModel) {
                    lastModel = indexModel;
                }else {
                    if (lastModel.startTime < indexModel.startTime && indexModel.startTime < currentTime) {
                        lastModel = indexModel;
                    }
                }
            }
            
            self.currentEffectType = lastModel.identification;
        }
    }
}

#pragma mark - API
- (void)calculateEffectResult{
    
    // 获取最后一次的特效位置数组
    NSMutableArray<EffectIndexModel *> *lastEffectIndexResult;
    
    if (self.totalTimeModel.count == 1) {
        EffectIndexModel *defaultEffectIndex = [EffectIndexModel new];
        defaultEffectIndex.startTime = 0;
        defaultEffectIndex.identification = 0;
        
        lastEffectIndexResult = [@[defaultEffectIndex] mutableCopy];
    }else {
        NSArray<EffectIndexModel *> *effectIndexResult = self.totalTimeModel[self.totalTimeModel.count - 2].effectIndexResult;
        lastEffectIndexResult = [effectIndexResult mutableCopy];
    }
    
    // 插入特效
    EffectIndexModel *currentEffectIndexModel = [EffectIndexModel new];
    currentEffectIndexModel.startTime = self.currentTimeModel.startTime;
    currentEffectIndexModel.identification = self.currentTimeModel.identification;
    [lastEffectIndexResult addObject:currentEffectIndexModel];
 
    // 获取被覆盖的特效位置数据
    CGFloat effectEndTime = self.currentTimeModel.startTime + self.currentTimeModel.duration;
    NSMutableArray<EffectIndexModel *> *coveredEffectIndexModel = [NSMutableArray array];
    for (EffectIndexModel *effectIndexModel in lastEffectIndexResult) {
        if (effectIndexModel.startTime >= self.currentTimeModel.startTime) {
            if (effectIndexModel.startTime <= effectEndTime) {
                if (effectIndexModel != currentEffectIndexModel) {
                    [coveredEffectIndexModel addObject:effectIndexModel];
                }
            }
        }
    }
    
    // 获取被覆盖的特效位置中最远的一个位置
    EffectIndexModel *farthestEffectIndexModel;
    for (EffectIndexModel *effectIndexModel in coveredEffectIndexModel) {
        if (!farthestEffectIndexModel) {
            farthestEffectIndexModel = effectIndexModel;
        } else {
            if (farthestEffectIndexModel.startTime < effectIndexModel.startTime) {
                farthestEffectIndexModel = effectIndexModel;
            }
        }
    }
    
    // 删除除了最远的一个特效以外的其它特效
    for (EffectIndexModel *effectIndexModel in coveredEffectIndexModel) {
        if (effectIndexModel != farthestEffectIndexModel) {
            [lastEffectIndexResult removeObject:effectIndexModel];
        }
    }
    
    // 被覆盖的特效位置中最远的一个位置设置到当前特效的尾部
    if (farthestEffectIndexModel) {
        
        //覆盖到了结尾
        if (effectEndTime == self.audioPlayer.duration) {
            [lastEffectIndexResult removeObject:farthestEffectIndexModel];
            farthestEffectIndexModel = nil;
        } else {
            farthestEffectIndexModel.startTime = effectEndTime;
        }
    } else if (effectEndTime != self.audioPlayer.duration) {
        
        // 在尾部插入最近一个特效
        EffectIndexModel *nearestEffectIndexModel;
        for (EffectIndexModel *effectIndexModel in lastEffectIndexResult) {
            if (effectIndexModel.startTime < self.currentTimeModel.startTime) {
                if (!nearestEffectIndexModel) {
                    nearestEffectIndexModel = effectIndexModel;
                }else {
                    if (nearestEffectIndexModel.startTime < effectIndexModel.startTime) {
                        nearestEffectIndexModel = effectIndexModel;
                    }
                }
            }
        }
        EffectIndexModel *defaultEffectIndex = [EffectIndexModel new];
        defaultEffectIndex.startTime = self.currentTimeModel.startTime + self.currentTimeModel.duration;
        defaultEffectIndex.identification = nearestEffectIndexModel.identification;
        [lastEffectIndexResult addObject:defaultEffectIndex];
    }
    
    // 设置特效位置
    [lastEffectIndexResult sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        EffectIndexModel *model1 = obj1;
        EffectIndexModel *model2 = obj2;
        return model1.startTime > model2.startTime;
    }];
    self.currentTimeModel.effectIndexResult = lastEffectIndexResult;
    
    for (EffectIndexModel *effectIndexModel in lastEffectIndexResult) {
        NSLog(@"effect : %ld , startTime : %.2f",effectIndexModel.identification, effectIndexModel.startTime);
    }
    NSLog(@"\n");
}

- (void)dealloc{
    NSLog(@" 方法调用了 %s ", __func__);
}
@end
