//
//  VideoEffectData.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/3/1.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "VideoEffectData.h"

@implementation VideoEffectData

+ (NSArray<VideoEffectModel *> *)data{
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *iconRootPath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"VideoEffectResources"] stringByAppendingPathComponent:@"icon"];
    
    NSArray<NSString *> *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:iconRootPath error:nil];
    
    for (NSString *fileName in fileList) {
        
        VideoEffectModel *model = [[VideoEffectModel alloc] init];
        model.thumbnail = [iconRootPath stringByAppendingPathComponent:fileName];
        model.text = [fileName substringWithRange:NSMakeRange(3, fileName.length - 10)];
        model.effectType = [[fileName substringToIndex:2] integerValue];
        [array addObject:model];
    }
    
    return array;
}

@end
