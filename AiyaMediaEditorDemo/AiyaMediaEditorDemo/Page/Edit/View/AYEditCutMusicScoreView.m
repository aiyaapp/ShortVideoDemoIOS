//
//  AYEditCutMusicScoreView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/2.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYEditCutMusicScoreView.h"

#import <AiyaMediaEditor/AiyaMediaEditor.h>
#import <AVFoundation/AVFoundation.h>

static const NSUInteger sampleCount = 40;

@interface AYEditCutMusicScoreView ()

@property (nonatomic, strong) NSArray *audioAveragePowerData;

@property (nonatomic, assign) CGPoint point;

@property (nonatomic, assign) CGFloat audioDuration;

@end

@implementation AYEditCutMusicScoreView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (void)setAudioURL:(NSURL *)audioURL{
    _audioURL = audioURL;
    
    self.audioAveragePowerData = [AYAudioAveragePower averagePowerWithAudioURL:audioURL sampleCount:sampleCount];
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioURL.path]];
    self.audioDuration = CMTimeGetSeconds(asset.duration);
}

- (void)setStartTime:(CGFloat)startTime{
    _startTime = startTime;
    
    [self setNeedsDisplay];
}

- (void)setDuration:(CGFloat)duration{
    _duration = duration;
    
    [self setNeedsDisplay];
}

#pragma mark - drag and draw

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint point = [touch locationInView:self];
    
    self.point = point;
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    
    [self moveHandle:lastPoint];
    
    self.point = lastPoint;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cutMusicScoreViewEndTouch)]) {
        [self.delegate cutMusicScoreViewEndTouch];
    }
}

- (void)moveHandle:(CGPoint)point{
    CGFloat offset = (point.x - self.point.x) / 2.0;

    // 如果低于0
    if (self.startTime / self.audioDuration * self.bounds.size.width + offset < 0) {
        return;
    }
    
    // 如果宽度超出了
    if ((self.startTime + self.duration) / self.audioDuration * self.bounds.size.width + offset > self.bounds.size.width) {
        return;
    }
    
    self.startTime = self.startTime + self.audioDuration / self.bounds.size.width * offset;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cutMusicScoreViewStartTime:)]) {
        [self.delegate cutMusicScoreViewStartTime:self.startTime];
    }
}

- (void)drawRect:(CGRect)rect  {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat midY = CGRectGetMidY(rect);
    NSUInteger count = self.audioAveragePowerData.count;
    
    // 绘制波形图
    for (NSUInteger i = 0; i < count; i ++) {
        
        float sample = [self.audioAveragePowerData[i] floatValue];
        
        CGContextMoveToPoint(context, self.bounds.size.width / (count + 1) * (i + 1) ,midY * (1 - sample));
        CGContextAddLineToPoint(context, self.bounds.size.width / (count + 1) * (i + 1), midY * (1 + sample));
    }
    
    // 波形图上色
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0);
    CGContextSetLineWidth(context, 4);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextStrokePath(context);
    
    // 绘制四边形
    CGContextAddRect(context, CGRectMake(self.bounds.size.width / self.audioDuration * self.startTime, 0, self.bounds.size.width / self.audioDuration * self.duration, self.bounds.size.height));
    [[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0] set];
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    CGContextFillPath(context);
    
    [super drawRect:rect];
}

@end
