//
//  AYAudioMixEffect.h
//  AiyaMediaEditor
//
//  Created by 汪洋 on 2018/2/1.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 音频混合效果
 */
@interface AYAudioMixEffect : NSObject

/**
 输入的主音频文件路径
 */
@property (nonatomic, strong) NSString *inputMainPath;

/**
 主音频音量
 */
@property (nonatomic, assign) CGFloat mainVolume;

/**
 输入的副音频文件路径
 */
@property (nonatomic, strong) NSString *inputDeputyPath;

/**
 副音频开始时间
 */
@property (nonatomic, assign) CGFloat deputyStartTime;

/**
 副音频音量
 */
@property (nonatomic, assign) CGFloat deputyVolume;

/**
 输出的音频文件路径
 */
@property (nonatomic, strong) NSString *outputPath;

/**
 开始处理音频文件
 
 */
- (BOOL)process;

@end
