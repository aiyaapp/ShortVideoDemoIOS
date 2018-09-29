//
//  AYAudioAveragePower.h
//  AiyaMediaEditor
//
//  Created by 汪洋 on 2018/2/1.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AYAudioAveragePower : NSObject

/**
 获取音频波形数据

 @param url 音频路径
 @param sampleCount 采样次数
 @return 波形数据
    range: 0 -> 1.0
    count: sampleCount
 */
+ (NSArray *)averagePowerWithAudioURL:(NSURL *)url sampleCount:(NSUInteger)sampleCount;

@end
