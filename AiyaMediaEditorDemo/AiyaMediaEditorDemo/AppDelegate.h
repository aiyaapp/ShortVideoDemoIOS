//
//  AppDelegate.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectTimeModel.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// 音乐名
@property (nonatomic, copy) NSString *musicName;

// 音乐文件路径
@property (nonatomic, copy) NSString *musicPath;

// 特效时间数据集合
@property (nonatomic, strong) NSMutableArray<EffectTimeModel *> *totalTimeModel;

// 找到当前时间的对应的特效
- (NSUInteger)effectTypeWithTime:(CGFloat)time;

@end
