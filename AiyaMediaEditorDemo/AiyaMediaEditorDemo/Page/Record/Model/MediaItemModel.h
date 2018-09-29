//
//  MediaItemModel.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/25.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface MediaItemModel : NSObject

@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, assign) CGFloat videoSeconds;

@property (nonatomic, strong) NSString *audioPath;
@property (nonatomic, strong) NSString *audioTempoPath;

@property (nonatomic, assign) CMTime speed;

@end
