//
//  AYAudioTempoEffect.h
//  AiyaMediaEditor
//
//  Created by 汪洋 on 2018/1/30.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/**
 音频速度效果
 */
@interface AYAudioTempoEffect : NSObject

/**
 输入的音频文件路径
 */
@property (nonatomic, strong) NSString *inputPath;

/**
 输出的音频文件路径
 */
@property (nonatomic, strong) NSString *outputPath;

/**
 节奏
 Range: 0.25 -> 4.0
 Default: 1.0
 */
@property (nonatomic, assign) CGFloat tempo;

/**
 开始处理音频文件

 */
- (BOOL)process;

@end
