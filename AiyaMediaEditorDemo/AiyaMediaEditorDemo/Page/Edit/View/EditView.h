//
//  EditView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditViewDelegate <NSObject>
@optional

- (void)editViewBack;

- (void)editViewNext;

- (void)editViewOriginalAudioMute:(BOOL)mute;

- (void)editViewSelectMusic;

- (void)editViewCutMusicClick;

- (void)editViewCutMusic:(CGFloat)startTime;

- (void)editViewCutMusicFinish;

- (void)editViewVolumeClick;

- (void)editViewAudioVolume:(CGFloat)volume musicVolume:(CGFloat)musicVolume;

- (void)editViewVolumeFinish;

- (void)editViewAddEffect;

- (void)editViewWaterMask:(BOOL)show;

@end

@interface EditView : UIView

@property (nonatomic, weak) id<EditViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *preview;

@property (nonatomic, assign) CGFloat musicStartTime;

@property (nonatomic, copy) NSString *musicPath;

@property (nonatomic, assign) CGFloat audioDuration;

@property (nonatomic, assign) CGFloat recordAudioVolume;

@property (nonatomic, assign) CGFloat musicVolume;

- (void)showCutMusicView;

- (void)hideCutMusicView;

- (void)showMixVolume;

- (void)hideMixVolume;

@end
