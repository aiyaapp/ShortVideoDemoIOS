//
//  AYEditCutAudioView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/2.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AYEditCutAudioViewDelegate <NSObject>
@optional

/**
 手指滑动时更新时间
 */
- (void)editCutAudioUpdateStartTime:(CGFloat)startTime;

/**
 更新结束
 */
- (void)editCutAudioUpdateFinish;

@end

@interface AYEditCutAudioView : UIView

@property (nonatomic, weak) id<AYEditCutAudioViewDelegate> delegate;

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
