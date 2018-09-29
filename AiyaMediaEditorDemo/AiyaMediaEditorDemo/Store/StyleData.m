//
//  StyleData.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/25.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "StyleData.h"

@implementation StyleData

+ (NSArray<StyleModel *> *)data{
    NSMutableArray *array = [NSMutableArray array];
    
    NSString *styleRootPath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"FilterResources"] stringByAppendingPathComponent:@"filter"];
    NSString *iconRootPath = [[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:@"FilterResources"] stringByAppendingPathComponent:@"icon"];

    NSArray<NSString *> *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:styleRootPath error:nil];
    
    for (NSString *fileName in fileList) {
        
        NSString *path = [styleRootPath stringByAppendingPathComponent:fileName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            continue;
        }
        
        NSString *name = [fileName substringWithRange:NSMakeRange(0, fileName.length - 4)];

        StyleModel *model = [[StyleModel alloc] init];
        model.thumbnail = [iconRootPath stringByAppendingPathComponent:[name stringByAppendingString:@".png"]];
        model.text = [name substringFromIndex:2];
        model.path = path;
        [array addObject:model];
    }
    
    return array;
}

@end
