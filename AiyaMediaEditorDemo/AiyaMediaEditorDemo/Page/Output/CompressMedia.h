//
//  CompressMedia.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/28.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CompressMedia : NSObject

@property (nonatomic, copy) NSURL *inputURL;

@property (nonatomic, copy) NSURL *outputURL;

/**
 设置视频码率
 
 @param bitrate 码率
 */
- (void)setVideoBitrate:(unsigned int)bitrate;

/**
 设置音频码率
 
 @param bitrate 码率
 */
- (void)setAudioBitrate:(unsigned int)bitrate;

/**
 开始导出
 */
- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(BOOL))handler;

@end
