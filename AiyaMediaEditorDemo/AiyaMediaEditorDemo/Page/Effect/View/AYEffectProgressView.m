//
//  AYEffectProgressView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/5.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYEffectProgressView.h"

#import <AVFoundation/AVFoundation.h>

@interface AYEffectProgressView ()

/**
 播放器当前时间的位置
 */
@property (nonatomic, assign) CGFloat currentTime;

/**
 视频时间的总长度
 */
@property (nonatomic, assign) CGFloat audioDuration;

/**
 上一次手指点击的位置
 */
@property (nonatomic, assign) CGPoint point;

@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;

@property (nonatomic, strong) NSMutableArray<UIImage *> *images;

@property (nonatomic, assign) NSInteger imageCount;

@property (nonatomic, assign) BOOL isTouch;

@property (nonatomic, assign) CGFloat progress;

@property (nonatomic, strong) UIImage *imageScreenShot;

@end

@implementation AYEffectProgressView

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (!self.imageGenerator && self.videoURL) {
        [self generatImages];
    }
}

#pragma mark - public API
- (void)setEffectTimeArr:(NSArray<EffectTimeModel *> *)effectTimeArr{
    _effectTimeArr = effectTimeArr;
    
    [self setNeedsDisplay];
}

- (void)setAudioURL:(NSURL *)audioURL{
    _audioURL = audioURL;
    
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:audioURL.path]];
    self.audioDuration = CMTimeGetSeconds(asset.duration);
    
    [self setNeedsDisplay];
}


- (void)setProgress:(CGFloat)progress{    
    _progress = progress;
    
    if (self.isTouch) {
        return;
    }
    
    self.currentTime = self.audioDuration * progress;
    
    [self setNeedsDisplay];
}

#pragma mark - private API
// 生成进度
- (void)generatImages{
    AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
    AVAssetTrack *videoAssetTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];

    CGSize videoSize = videoAssetTrack.naturalSize;
    CGAffineTransform firstTransform = videoAssetTrack.preferredTransform;
    
    if (firstTransform.a == 0 && firstTransform.d == 0 && (firstTransform.b == 1.0 || firstTransform.b == -1.0) && (firstTransform.c == 1.0 || firstTransform.c == -1.0)) {

        videoSize.height = videoAssetTrack.naturalSize.width;
        videoSize.width = videoAssetTrack.naturalSize.height;
    }
    
    _imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    
    Float64 durationSeconds = CMTimeGetSeconds([asset duration]);
    
    NSMutableArray *times = [NSMutableArray array];
    NSInteger count = self.bounds.size.width / (self.bounds.size.height * videoSize.width / videoSize.height);
    
    for (int x = 0; x <= count; x++) {
        CMTime frameTime = CMTimeMakeWithSeconds(durationSeconds * x / count, 600);
        [times addObject:[NSValue valueWithCMTime:frameTime]];
    }
    
    _imageCount = times.count;
    _images = [NSMutableArray arrayWithCapacity:times.count];
    
    [self.imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        
         if (result == AVAssetImageGeneratorSucceeded) {
             [self.images addObject:[UIImage imageWithCGImage:image]];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self setNeedsDisplay];
             });
         }
        
         if (result == AVAssetImageGeneratorFailed) {
             NSLog(@"Failed with error: %@", [error localizedDescription]);
         }
         if (result == AVAssetImageGeneratorCancelled) {
             NSLog(@"Canceled");
         }
     }];
}


#pragma mark - drag and draw
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint point = [touch locationInView:self];
    
    self.point = point;
    
    self.isTouch = YES;
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint lastPoint = [touch locationInView:self];
    
    [self moveHandle:lastPoint];
    
    self.point = lastPoint;
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    // 跳转到相应的时间
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectProgressViewSeekTo:)]) {
        [self.delegate effectProgressViewSeekTo:self.currentTime / self.audioDuration];
    }
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
    self.isTouch = NO;
}

// 划动时的处理
- (void)moveHandle:(CGPoint)point{
    CGFloat offset = (point.x - self.point.x) / 2.0;
    
    // 如果低于0
    if (self.currentTime / self.audioDuration * self.bounds.size.width + offset < 0) {
        self.currentTime = 0;
        [self setNeedsDisplay];
        return;
    }

    // 如果宽度超出了
    if (self.currentTime / self.audioDuration * self.bounds.size.width + offset > self.bounds.size.width) {
        self.currentTime = self.audioDuration;
        [self setNeedsDisplay];
        return;
    }
    
    self.currentTime = self.currentTime + self.audioDuration / self.bounds.size.width * offset;
    
    [self setNeedsDisplay];
}

// 绘制
- (void)drawRect:(CGRect)rect{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor clearColor] set];
    
    // 绘制视频缩略图
    if (self.images.count == self.imageCount && !self.imageScreenShot) {
        UIGraphicsPushContext(context);
        
        UIGraphicsBeginImageContext(CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height * 2));
        
        for (int x = 0; self.imageCount > 0 && x < self.images.count; x++) {
            UIImage *image = [self.images objectAtIndex:x];
            
            [image drawInRect:CGRectMake((CGFloat)x / self.imageCount * rect.size.width * 2, 0, rect.size.width / self.imageCount * 2, rect.size.height * 2)];
        }
        
        self.imageScreenShot  = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIGraphicsPopContext();
    }
    
    if (self.imageScreenShot) { // 最好单独开一个自定义进行绘制
        [self.imageScreenShot drawInRect:CGRectMake(0, 2, rect.size.width, rect.size.height - 4)];
    }
    
    // 绘制特效时间
    UIGraphicsPushContext(context);
    
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef newContext = UIGraphicsGetCurrentContext();
    
    for (int x = 0; x < self.effectTimeArr.count; x++) {
        EffectTimeModel *timeModel = [self.effectTimeArr objectAtIndex:x];
        CGContextAddRect(newContext, CGRectMake(timeModel.startTime / self.audioDuration * self.bounds.size.width, 0, timeModel.duration / self.audioDuration * self.bounds.size.width, self.bounds.size.height));
        [timeModel.effectColor set];
        CGContextFillPath(newContext);
    }
    
    UIImage *effectTimeImg = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    UIGraphicsPopContext();
    
    [effectTimeImg drawInRect:CGRectMake(0, 2, rect.size.width, rect.size.height - 4) blendMode:kCGBlendModeNormal alpha:0.8];
    
    // 绘制游标
    CGContextSetAlpha(context, 1);
    CGContextMoveToPoint(context, self.currentTime / self.audioDuration * self.bounds.size.width, 0);
    CGContextAddLineToPoint(context, self.currentTime / self.audioDuration * self.bounds.size.width, self.bounds.size.height);
    
    CGContextSetRGBStrokeColor(context, 0xFE/255.0, 0x70/255.0, 0x44/255.0, 1.0);
    CGContextSetLineWidth(context, 4);
    CGContextSetLineCap(context, kCGLineCapButt);
    CGContextStrokePath(context);
    
    [super drawRect:rect];
}

@end
