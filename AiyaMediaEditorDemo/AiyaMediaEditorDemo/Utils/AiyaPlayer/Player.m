//
//  Player.m
//  Player
//
//  Created by qianjianeng on 16/1/31.
//  Copyright © 2016年 SF. All rights reserved.
//

#import "Player.h"
#import "PlayerStateView.h"

/**
 播放器的几种状态
 */
typedef NS_ENUM(NSInteger, PlayerState) {
    PlayerStateInit     = 0,
    PlayerStatePlaying  = 1,
    PlayerStatePause    = 2,
    PlayerStateStopped  = 3,
};

@interface Player () <PlayerStateViewDelegate>

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;
@property (nonatomic, strong) NSObject *playbackTimeObserver;

@property (nonatomic, copy) NSString *path;

@property (nonatomic, assign) PlayerState state;

@property (nonatomic, assign) CGFloat playProgress; //播放进度

@property (nonatomic, strong) PlayerStateView *stateView; //播放器控制
@property (nonatomic, strong) PlayerPreview *preview; //影片预览

@end

@implementation Player

- (instancetype)initWithPlayerView:(UIView *)playerView{
    self = [super init];
    if (self) {
        _preview = [[PlayerPreview alloc]init];
        _stateView = [[PlayerStateView alloc]init];
        self.stateView.delegate = self;

        [self.preview setClipsToBounds:YES];
        [self.stateView setClipsToBounds:YES];

        [playerView addSubview:self.preview];
        [playerView addSubview:self.stateView];

        // 使用autoLayout约束，禁止将AutoresizingMask转换为约束
        [self.preview setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.stateView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        {
            NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:_preview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:playerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:_preview attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:playerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:_preview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:playerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:_preview attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:playerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            NSArray *array = [NSArray arrayWithObjects:constraint1, constraint2, constraint3, constraint4 ,nil];
            [playerView addConstraints:array];
        }
        
        {
            NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:_stateView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:playerView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
            NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:_stateView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:playerView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
            NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:_stateView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:playerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
            NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:_stateView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:playerView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
            NSArray *array = [NSArray arrayWithObjects:constraint1, constraint2, constraint3, constraint4 ,nil];
            [playerView addConstraints:array];
        }
    }
    return self;
}

- (void)setPlayerPath:(NSString *)path{
    [self releasePlayer];
    
    self.path = path;
    
    self.playProgress = 0;
    
    if (!path){
        return;
    }

    NSLog(@"开始播放本地视频 %@",self.path);
    NSURL *url = [NSURL fileURLWithPath:self.path];
    AVAsset *videoAsset  = [AVURLAsset URLAssetWithURL:url options:nil];
    self.currentPlayerItem = [AVPlayerItem playerItemWithAsset:videoAsset];

    self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
    self.playerLayer = (AVPlayerLayer *)self.preview.layer;
    [self.playerLayer setContents:(id)[UIColor blackColor]];
    [self.playerLayer setPlayer:self.player];
    [self.playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    [self.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    self.state = PlayerStateInit;
}

#pragma mark - 播放器状态观察
//播放器状态观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if (playerItem != self.currentPlayerItem)
        return;
    
    if ([keyPath isEqualToString:@"status"]) {//监听播放器的状态
        if ([playerItem status] == AVPlayerStatusReadyToPlay) {
            [self readyToPlay:playerItem];
            
        } else if ([playerItem status] == AVPlayerStatusFailed || [playerItem status] == AVPlayerStatusUnknown) {
            [self stop];
        }
    }
}

//开始播放
- (void)readyToPlay:(AVPlayerItem *)playerItem{
    NSLog(@"readyToPlay");
    
    //更新视频进度
    __block CGFloat duration = playerItem.duration.value / playerItem.duration.timescale; //视频总时间
    __weak __typeof(self)weakSelf = self;
    self.playbackTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        CGFloat current = playerItem.currentTime.value / playerItem.currentTime.timescale;
        if (current > duration) {
            duration = current;
        }
        
        if (duration != 0){
            CGFloat progress = current / duration;
            
            if (strongSelf.playProgress != progress) {
                strongSelf.playProgress = progress;
            }
        }
    }];
}

//播放已经结束
#pragma mark AVPlayerItemDidPlayToEndTimeNotification
- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    NSLog(@"playToEnd");
    
    [self stop];
    
    if (self.loopPlay) {
        [self play];
    }
}

#pragma mark PlayerStateViewDelegate
- (void)playerStateViewOnStopBtClick{
    switch (self.state) {
        case PlayerStateInit:
            break;
        case PlayerStatePlaying:
            [self pause];
            break;
        case PlayerStatePause:
            [self play];
            break;
        case PlayerStateStopped:
            [self play];
            break;
    }
}

#pragma mark - 播放器控制
- (void)play{
    NSLog(@"play");
    
    if (!self.path){
        return;
    }
    
    if (!self.currentPlayerItem){
        return;
    }
    
    self.state = PlayerStatePlaying;
    [self.player play];
}

- (void)pause{
    NSLog(@"pause");

    self.state = PlayerStatePause;
    [self.player pause];
}

- (void)unPause{
    NSLog(@"unPause");

    self.state = PlayerStatePlaying;
    [self.player play];
}

- (void)stop{
    NSLog(@"stop");

    self.state = PlayerStateStopped;
    [self.player pause];
    [self.player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
}

- (void)seekTo:(CGFloat)progress{
    if (self.state == PlayerStatePlaying) {
        [self pause];
    }
    
    [self.player seekToTime:CMTimeMultiplyByRatio(self.currentPlayerItem.duration, progress * 10000, 10000)];
}

-(void)setState:(PlayerState)state{
    _state = state;
    switch (state) {
        case PlayerStateInit:
            break;
        case PlayerStatePlaying:{
            [self.stateView setHiddenStopBt];
        }
            break;
        case PlayerStatePause:{
            [self.stateView setShowStopBt];
        }
            break;
        case PlayerStateStopped:{
            [self.stateView setShowStopBt];
        }
            break;
    }
}

- (void)releasePlayer{

    if (self.playbackTimeObserver) {
        [self.player removeTimeObserver:self.playbackTimeObserver];
        self.playbackTimeObserver = nil;
    }
    
    if (self.currentPlayerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self.currentPlayerItem removeObserver:self forKeyPath:@"status"];
        self.currentPlayerItem = nil;
    }
}

- (void)dealloc{
    [self releasePlayer];
}
@end
