//
//  Player.h
//  Player
//
//  Created by qianjianeng on 16/1/31.
//  Copyright © 2016年 SF. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

#import "PlayerPreview.h"

@interface Player : NSObject

@property (nonatomic, readonly) CGFloat playProgress; //播放进度

/**
 是否循环播放
 */
@property (nonatomic, assign) BOOL loopPlay;

/**
 初始设置播放器播放的view
 */
- (instancetype)initWithPlayerView:(UIView *)playerView;

/**
 设置视频的路径
 */
- (void)setPlayerPath:(NSString *)path;

/**
 播放
 */
- (void)play;

/**
 暂停
 */
- (void)pause;

/**
 继续
 */
- (void)unPause;

/**
 停止
 */
- (void)stop;

/**
 跳转
 */
- (void)seekTo:(CGFloat)progress;

@end
