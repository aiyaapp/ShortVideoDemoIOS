//
//  AYRecordProgressView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYRecordProgressView.h"

@interface AYRecordProgressView ()

@end

@implementation AYRecordProgressView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    bezierPath.lineCapStyle = kCGLineCapButt;
    bezierPath.lineWidth = 10;
    
    UIColor *orengeColor =  [UIColor colorWithRed:254/255.0 green:112/255.0 blue:68/255.0 alpha:1/1.0];
    
    CGFloat percentCount = 0;
    for (int x = 0; x < self.mediaItemArr.count; x++) {
        MediaItemModel *model = self.mediaItemArr[x];

        CGFloat percent = model.videoSeconds / self.longestVideoSeconds;

        // 绘制已经录制的片段
        [bezierPath removeAllPoints];
        [bezierPath moveToPoint:CGPointMake(percentCount * rect.size.width, rect.size.height / 2)];
        [bezierPath addLineToPoint:CGPointMake((percentCount + percent) * rect.size.width, rect.size.height / 2)];

        [orengeColor setStroke];
        [bezierPath stroke];
        
        // 绘制结束的白色间隔
        [bezierPath removeAllPoints];
        [bezierPath moveToPoint:CGPointMake((percentCount + percent) * rect.size.width - 3, rect.size.height / 2)];
        [bezierPath addLineToPoint:CGPointMake((percentCount + percent) * rect.size.width, rect.size.height / 2)];
        
        [[UIColor whiteColor] setStroke];
        [bezierPath stroke];
        
        percentCount += percent;
    }
    
    if (self.recordingMediaItem.videoSeconds > 0) {
        CGFloat percent = self.recordingMediaItem.videoSeconds / self.longestVideoSeconds;
        
        // 绘制正在录制的片段
        [bezierPath removeAllPoints];
        [bezierPath moveToPoint:CGPointMake(percentCount * rect.size.width, rect.size.height / 2)];
        [bezierPath addLineToPoint:CGPointMake((percentCount + percent) * rect.size.width, rect.size.height / 2)];
        
        [orengeColor setStroke];
        [bezierPath stroke];
    }
}

@end
