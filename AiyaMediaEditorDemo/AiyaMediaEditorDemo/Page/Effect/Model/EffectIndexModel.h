//
//  EffectIndexModel.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/7.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface EffectIndexModel : NSObject

// 视频特效的ID
@property (nonatomic, assign) NSUInteger identification;

// 特效开始的时间
@property (nonatomic, assign) CGFloat startTime;

@end
