//
//  EffectView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/3.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectTimeModel.h"
#import "EffectCellModel.h"

@protocol EffectViewDelegate <NSObject>
@optional

// 返回按钮的回调
- (void)effectViewBack;

// 撤销
- (void)effectViewUndo;

// 划动进度条时的回调
- (void)effectViewSeekTo:(CGFloat)progress;

// 按住特效选择按钮时的回调
- (void)effectViewTouchDownModel:(EffectCellModel *)model;

// 抬起特效选择按钮时的回调
- (void)effectViewTouchUp;

@end

@interface EffectView : UIView

@property (nonatomic, weak) id<EffectViewDelegate> delegate;

@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, strong) NSURL *audioURL;

// 预览的view
@property (nonatomic, strong, readonly) UIView *preview;

// 设置特效时长的数据
@property (nonatomic, strong) NSArray<EffectTimeModel *> *effectTimeArr;

// 设置底部特效选择器的数据
@property (nonatomic, strong) NSArray<EffectCellModel *> *selectorDataArr;

// 设置播放器的进度
- (void)setProgress:(CGFloat)progress;
@end
