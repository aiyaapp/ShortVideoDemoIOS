//
//  MusicModel.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/9.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface MusicModel : NSObject

@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *musicPath;
@property (nonatomic, assign) CGFloat musicDuration;

@end
