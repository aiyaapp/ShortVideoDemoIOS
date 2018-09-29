//
//  VideoEffectHandler.h
//
//  Created by 汪洋 on 2017/9/30.
//  Copyright © 2017年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <CoreMedia/CoreMedia.h>

@interface VideoEffectHandler : UIView

/**
 设置特效类型

 @param effectType 特效类型
 */
- (void)setEffectType:(NSInteger)effectType;

/**
 使用指定的特效类型处理sampleBuffer封装的数据

 @param sampleBuffer 一帧视频数据,格式为yuv420f
 @param naturalSize 视频大小
 @param radians 视频内容的旋转弧度
 @param isPortrait 视频内容是否是垂直的
 @return 返回一帧BGRA视频数据
 */
- (CMSampleBufferRef)process:(CMSampleBufferRef)sampleBuffer naturalSize:(CGSize)naturalSize radians:(GLfloat)radians isPortrait:(BOOL)isPortrait;

@end
