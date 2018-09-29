//
//  AYEditCutAudioView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/2.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYEditCutAudioView.h"
#import "AYEditCutMusicScoreView.h"

#import <Masonry/Masonry.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AYEditCutAudioView () <AYEditCutMusicScoreViewDelegate>

@property (nonatomic, strong) AYEditCutMusicScoreView *cutMusicScoreView;

@property (nonatomic, strong) UIButton *okBt;

@property (nonatomic, strong) UILabel *startTimeLabel;

@end

@implementation AYEditCutAudioView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        UILabel *descriptionLable = [[UILabel alloc] init];
        descriptionLable.text = @"左右拖动声谱以剪取音乐";
        descriptionLable.textColor = [UIColor whiteColor];
        descriptionLable.font = [UIFont systemFontOfSize:14];
        
        _okBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.okBt setImage:[UIImage imageNamed:@"btn_ok_n"] forState:UIControlStateNormal];
        [self.okBt setImage:[UIImage imageNamed:@"btn_ok_p"] forState:UIControlStateHighlighted];
        [self.okBt addTarget:self action:@selector(onOkBtClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _cutMusicScoreView = [AYEditCutMusicScoreView new];
        self.cutMusicScoreView.delegate = self;
        
        UIImageView *popImageView = [UIImageView new];
        popImageView.image = [[UIImage imageNamed:@"pic_bubbles"] resizableImageWithCapInsets:UIEdgeInsetsMake(3, 10, 9, 10)];
        
        _startTimeLabel = [UILabel new];
        self.startTimeLabel.textColor = [UIColor whiteColor];
        self.startTimeLabel.font = [UIFont systemFontOfSize:12];
        self.startTimeLabel.text = @"当前从00:00开始";
        
        [self addSubview:descriptionLable];
        [self addSubview:self.okBt];
        [self addSubview:popImageView];
        [self addSubview:self.startTimeLabel];
        [self addSubview:self.cutMusicScoreView];
        
        [self.cutMusicScoreView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(10);
            make.right.equalTo(self.mas_right).offset(-10);
            make.bottom.equalTo(self.mas_bottom).offset(-5);
            make.height.mas_equalTo(100);
        }];
        
        [popImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.cutMusicScoreView.mas_top).offset(-25);
            make.height.mas_equalTo(23);
            make.width.equalTo(self.startTimeLabel.mas_width).offset(10);
        }];
        
        [self.startTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(popImageView.mas_left).offset(10);
            make.top.equalTo(popImageView.mas_top).offset(3);
            make.bottom.equalTo(popImageView.mas_bottom).offset(-9);
        }];
        
        [descriptionLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(popImageView.mas_top).offset(-20);
            make.centerX.equalTo(self.mas_centerX);
        }];
        
        [self.okBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(descriptionLable.mas_right).offset(22);
            make.centerY.equalTo(descriptionLable.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(32, 32));
        }];
    }
    return self;
}

- (void)setAudioURL:(NSURL *)audioURL{
    _audioURL = audioURL;
    
    self.cutMusicScoreView.audioURL = audioURL;
}

- (void)setStartTime:(CGFloat)startTime{
    _startTime = startTime;
    
    self.cutMusicScoreView.startTime = startTime;
}

- (void)setDuration:(CGFloat)duration{
    _duration = duration;
    
    self.cutMusicScoreView.duration = duration;
}

#pragma mark - AYEditCutMusicScoreViewDelegate

- (void)cutMusicScoreViewStartTime:(CGFloat)startTime{
    _startTime = startTime;
    
    self.startTimeLabel.text = [NSString stringWithFormat:@"当前从%02ld:%02ld开始",(NSInteger)startTime / 60, (NSInteger)startTime % 60];
}

- (void)cutMusicScoreViewEndTouch{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editCutAudioUpdateStartTime:)]) {
        [self.delegate editCutAudioUpdateStartTime:self.startTime];
    }
}

#pragma mark - Button Target
- (void)onOkBtClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editCutAudioUpdateFinish)]) {
        [self.delegate editCutAudioUpdateFinish];
    }
}

@end
