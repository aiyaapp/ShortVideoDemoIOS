//
//  AYEffectProgressView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/5.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectTimeModel.h"

@protocol AYEffectProgressViewDelegate <NSObject>
@optional

// 划动进度条的回调
- (void)effectProgressViewSeekTo:(CGFloat)progress;

@end

@interface AYEffectProgressView : UIControl

@property (nonatomic, weak) id<AYEffectProgressViewDelegate> delegate;

// 时间模型数组
@property (nonatomic, weak) NSArray<EffectTimeModel *> *effectTimeArr;

// 设置视频的URL
@property (nonatomic, strong) NSURL *videoURL;

// 设置音频的URL
@property (nonatomic, strong) NSURL *audioURL;

// 设置进度条进度
- (void)setProgress:(CGFloat)progress;

@end
