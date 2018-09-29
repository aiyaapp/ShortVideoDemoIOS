//
//  EffectCellModel.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/6.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoEffectModel.h"

@interface EffectCellModel : NSObject

@property (nonatomic, strong) VideoEffectModel *model;

// 视频特效显示在进度条上的颜色
@property (nonatomic, strong) UIColor *effectColor;


@end
