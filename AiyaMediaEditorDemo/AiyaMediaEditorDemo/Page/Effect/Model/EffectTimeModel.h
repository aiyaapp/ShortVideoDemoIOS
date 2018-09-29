//
//  EfffectTimeModel.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/5.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <AVKit/AVKit.h>
#import "EffectIndexModel.h"

#import <CoreGraphics/CoreGraphics.h>

@interface EffectTimeModel : NSObject

// 视频特效的ID
@property (nonatomic, assign) NSUInteger identification;

// 特效的颜色
@property (nonatomic, strong) UIColor *effectColor;

// 特效开始时间
@property (nonatomic, assign) CGFloat startTime;

// 特效持续时间
@property (nonatomic, assign) CGFloat duration;

// 当前全局的特效位置
@property (nonatomic, strong) NSArray<EffectIndexModel *> *effectIndexResult;

@end
