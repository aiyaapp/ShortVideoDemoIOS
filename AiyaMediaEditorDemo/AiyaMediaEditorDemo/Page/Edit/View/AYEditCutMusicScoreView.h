//
//  AYEditCutMusicScoreView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/2.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AYEditCutMusicScoreViewDelegate <NSObject>
@optional

/**
 手指划动时的时间的回调
 */
- (void)cutMusicScoreViewStartTime:(CGFloat)startTime;

/**
 手指抬起
 */
- (void)cutMusicScoreViewEndTouch;

@end

@interface AYEditCutMusicScoreView : UIControl

@property (nonatomic, weak) id <AYEditCutMusicScoreViewDelegate> delegate;

/**
 音频路径
 */
@property (nonatomic, strong)NSURL *audioURL;

/**
 裁切的开始时间
 */
@property (nonatomic, assign)CGFloat startTime;

/**
 裁切的时长
 */
@property (nonatomic, assign)CGFloat duration;

@end
