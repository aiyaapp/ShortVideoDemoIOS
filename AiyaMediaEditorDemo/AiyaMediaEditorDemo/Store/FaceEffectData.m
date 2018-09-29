//
//  FaceEffectData.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/25.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "FaceEffectData.h"

@implementation FaceEffectData

+ (NSArray<FaceEffectModel *> *)data{
    
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *effectRootPath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"EffectResources"] stringByAppendingPathComponent:@"effect"];
    NSString *iconRootPath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"EffectResources"] stringByAppendingPathComponent:@"icon"];

    NSArray<NSString *> *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:effectRootPath error:nil];
    
    for (NSString *fileName in fileList) {
        
        NSString *path = [effectRootPath stringByAppendingPathComponent:[fileName stringByAppendingPathComponent:@"meta.json"]];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            continue;
        }
        
        NSData *jsonData = [NSData dataWithContentsOfFile:path];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
        
        FaceEffectModel *model = [[FaceEffectModel alloc] init];
        model.thumbnail = [iconRootPath stringByAppendingPathComponent:[fileName stringByAppendingString:@".png"]];
        model.text = [dic objectForKey:@"name"];
        model.path = path;
        [array addObject:model];
    }
    
    return array;
}

@end
