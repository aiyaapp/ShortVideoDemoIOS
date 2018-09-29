//
//  EditView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "EditView.h"
#import "UIButton+ImageWithLable.h"
#import "AYEditCutAudioView.h"
#import "AYEditMixAudioView.h"

#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>

@interface EditView () <AYEditCutAudioViewDelegate, AYEditMixAudioViewDelegate>

@property (nonatomic, strong) UIView *preview;
@property (nonatomic, strong) AYEditCutAudioView *cutAudioView;
@property (nonatomic, strong) AYEditMixAudioView *mixAudioView;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) UIButton *originalAudioBt;

@property (nonatomic, strong) UIImageView *waterMaskIv;

@end

@implementation EditView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    _preview = [[UIView alloc] init];
    
    _containerView = [UIView new];
    
    UIButton *backBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBt setImage:[UIImage imageNamed:@"btn_return_n"] forState:UIControlStateNormal];
    [backBt setImage:[UIImage imageNamed:@"btn_return_p"] forState:UIControlStateHighlighted];
    [backBt addTarget:self action:@selector(onBackBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *nextBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBt setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBt addTarget:self action:@selector(onNextBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _originalAudioBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.originalAudioBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_sound itself_n"] withTitle:@"原声开" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [self.originalAudioBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_sound itself_p"] withTitle:@"原声关" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateSelected padding:5];
    [self.originalAudioBt addTarget:self action:@selector(onOriginalAudioBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *musicBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [musicBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_music_n"] withTitle:@"音乐" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [musicBt addTarget:self action:@selector(onMusicBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cutAudioBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [cutAudioBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_clip_n"] withTitle:@"剪音乐" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [cutAudioBt addTarget:self action:@selector(onCutAudioBtClick:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *audioBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [audioBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_voice_n"] withTitle:@"声音" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [audioBt addTarget:self action:@selector(onAudioBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *videoEffectBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [videoEffectBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_special effects_n"] withTitle:@"特效" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [videoEffectBt addTarget:self action:@selector(onEffectBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *waterMaskBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [waterMaskBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_watermark_n"] withTitle:@"水印" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [waterMaskBt addTarget:self action:@selector(onWaterMarkBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _waterMaskIv = [UIImageView new];
    [self.waterMaskIv setImage:[UIImage imageNamed:@"icon"]];
    self.waterMaskIv.hidden = YES;
    
    _cutAudioView = [[AYEditCutAudioView alloc] init];
    self.cutAudioView.delegate = self;
    self.cutAudioView.hidden = YES;

    _mixAudioView = [[AYEditMixAudioView alloc] init];
    self.mixAudioView.delegate = self;
    self.mixAudioView.hidden = YES;
    
    [self addSubview:self.preview];
    [self addSubview:self.waterMaskIv];
    [self addSubview:self.containerView];
    [self addSubview:backBt];
    [self.containerView addSubview:nextBt];
    [self.containerView addSubview:self.originalAudioBt];
    [self.containerView addSubview:musicBt];
    [self.containerView addSubview:cutAudioBt];
    [self.containerView addSubview:audioBt];
    [self.containerView addSubview:videoEffectBt];
    [self.containerView addSubview:waterMaskBt];
    [self addSubview:self.cutAudioView];
    [self addSubview:self.mixAudioView];
    
    [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.waterMaskIv mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(30);
        make.left.equalTo(self.mas_left).offset(30);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.width.mas_equalTo(80);
    }];
    
    [backBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top).offset(22);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    [nextBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(22);
        make.right.equalTo(self.mas_right);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
    }];
    
    [self.originalAudioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nextBt.mas_bottom).offset(5);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(60);
    }];
    
    [musicBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.originalAudioBt.mas_bottom).offset(5);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(60);
    }];
    
    [cutAudioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(musicBt.mas_bottom).offset(5);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(60);
    }];
    
    [audioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cutAudioBt.mas_bottom).offset(5);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(60);
    }];
    
    [videoEffectBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(audioBt.mas_bottom).offset(5);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(60);
    }];
    
    [waterMaskBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(videoEffectBt.mas_bottom).offset(5);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(60);
    }];
    
    [self.cutAudioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20);
        make.right.equalTo(self.mas_right).offset(-20);
        make.bottom.equalTo(self.mas_bottom);
        make.height.mas_equalTo(200);
    }];
    
    [self.mixAudioView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - Button Target
- (void)onBackBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewBack)]) {
        [self.delegate editViewBack];
    }
}

- (void)onNextBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewNext)]) {
        [self.delegate editViewNext];
    }
}

- (void)onOriginalAudioBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewOriginalAudioMute:)]) {
        [self.delegate editViewOriginalAudioMute:!bt.isSelected];
    }
    
    bt.selected = !bt.selected;
}

- (void)onMusicBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewSelectMusic)]) {
        [self.delegate editViewSelectMusic];
    }
}

- (void)onCutAudioBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewCutMusicClick)]) {
        [self.delegate editViewCutMusicClick];
    }
}

- (void)onAudioBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewVolumeClick)]) {
        [self.delegate editViewVolumeClick];
    }
}

- (void)onEffectBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewAddEffect)]) {
        [self.delegate editViewAddEffect];
    }
}

- (void)onWaterMarkBtClick:(UIButton *)bt{
    bt.selected = !bt.selected;

    self.waterMaskIv.hidden = !bt.selected;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewWaterMask:)]) {
        [self.delegate editViewWaterMask:bt.selected];
    }
}

#pragma mark - AYEditCutAudioViewDelegate
- (void)editCutAudioUpdateStartTime:(CGFloat)startTime{
    _musicStartTime = startTime;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewCutMusic:)]) {
        [self.delegate editViewCutMusic:startTime];
    }
}

- (void)editCutAudioUpdateFinish{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewCutMusicFinish)]) {
        [self.delegate editViewCutMusicFinish];
    }
}

#pragma mark - AYEditMixAudioViewDelegate
- (void)editMixAudioViewUpdateRecordAudioVolume:(CGFloat)recordAudioVolume musicVolume:(CGFloat)musicVolume{
    _recordAudioVolume = recordAudioVolume;
    _musicVolume = musicVolume;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewAudioVolume:musicVolume:)]) {
        [self.delegate editViewAudioVolume:recordAudioVolume musicVolume:musicVolume];
    }
}

- (void)editMixAudioViewUpdateFinish{
    if (self.recordAudioVolume == 0) { // 触发静音
        if (self.delegate && [self.delegate respondsToSelector:@selector(editViewOriginalAudioMute:)]) {
            [self.delegate editViewOriginalAudioMute:YES];
        }
        
        self.originalAudioBt.selected = YES;
    }else {
        self.originalAudioBt.selected = NO;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(editViewVolumeFinish)]) {
        [self.delegate editViewVolumeFinish];
    }
}

#pragma mark -API
- (void)showCutMusicView{
    self.cutAudioView.audioURL = [NSURL fileURLWithPath:self.musicPath];
    self.cutAudioView.startTime = self.musicStartTime;
    self.cutAudioView.duration = self.audioDuration;
    
    [self.cutAudioView setHidden:NO];
    [self.containerView setHidden:YES];
}

- (void)hideCutMusicView{
    [self.cutAudioView setHidden:YES];
    [self.containerView setHidden:NO];
}

- (void)showMixVolume{
    self.mixAudioView.recordAudioVolume = self.recordAudioVolume;
    self.mixAudioView.musicVolume = self.musicVolume;
    
    [self.mixAudioView setHidden:NO];
    [self.containerView setHidden:YES];
}

- (void)hideMixVolume{
    [self.mixAudioView setHidden:YES];
    [self.containerView setHidden:NO];
}

@end
