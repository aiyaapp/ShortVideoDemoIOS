//
//  PlayerStateView.h
//  aiya
//
//  Created by 汪洋 on 16/8/6.
//  Copyright © 2016年 aiya. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlayerStateViewDelegate <NSObject>
@optional
/**
 当点击停止按钮
 */
- (void)playerStateViewOnStopBtClick;

@end

@interface PlayerStateView : UIView

@property (nonatomic, weak) id<PlayerStateViewDelegate> delegate;

- (void)setHiddenStopBt;

- (void)setShowStopBt;

@end
