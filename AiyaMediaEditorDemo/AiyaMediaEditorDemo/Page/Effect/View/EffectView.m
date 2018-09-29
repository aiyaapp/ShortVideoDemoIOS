//
//  EffectView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/3.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "EffectView.h"
#import "AYEffectProgressView.h"
#import "AYEffectSelectorView.h"

#import "UIButton+ImageWithLable.h"
#import <Masonry/Masonry.h>

@interface EffectView () <AYEffectProgressViewDelegate, AYEffectSelectorViewDelegate>

// UI
@property (nonatomic, strong) UIView *preview;

@property (nonatomic, strong) UIButton *undoBt;

@property (nonatomic, strong) AYEffectProgressView *effectProgressView;

@property (nonatomic, strong) AYEffectSelectorView *effectSelectorView;

@end

@implementation EffectView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.backgroundColor =  [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1/1.0];
        
        UIButton *backBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBt setImage:[UIImage imageNamed:@"btn_return_n"] forState:UIControlStateNormal];
        [backBt setImage:[UIImage imageNamed:@"btn_return_p"] forState:UIControlStateHighlighted];
        [backBt addTarget:self action:@selector(onBackBtClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _effectSelectorView = [AYEffectSelectorView new];
        self.effectSelectorView.delegate = self;
        
        UIView *lineView = [UIView new];
        lineView.backgroundColor =  [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];

        UIView *undoLayout = [UIView new];
        undoLayout.backgroundColor = [UIColor blackColor];
        
        UILabel *undoDescriptionLabel = [UILabel new];
        undoDescriptionLabel.text = @"选择位置后, 按住使用效果";
        undoDescriptionLabel.textColor =  [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        undoDescriptionLabel.font = [UIFont systemFontOfSize:12];
        
        _undoBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.undoBt setHorizontalBtWithImage:[UIImage imageNamed:@"btn_back_n"] withTitle:@"撤销" font:[UIFont systemFontOfSize:12] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:4];
        [self.undoBt addTarget:self action:@selector(undoBtClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _effectProgressView = [AYEffectProgressView new];
        self.effectProgressView.backgroundColor = [UIColor clearColor];
        self.effectProgressView.delegate = self;
        
        _preview = [[UIView alloc] init];
        
        [self addSubview:backBt];
        [self addSubview:self.effectSelectorView];
        [self addSubview:lineView];
        [self addSubview:undoLayout];
        [undoLayout addSubview:undoDescriptionLabel];
        [undoLayout addSubview:self.undoBt];
        [self addSubview:self.effectProgressView];
        [self addSubview:self.preview];
        
        [backBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top).offset(22);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(44);
        }];
        
        [self.effectSelectorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.mas_bottom);
            make.right.equalTo(self.mas_right);
            make.height.mas_equalTo(90);
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.effectSelectorView.mas_top);
            make.height.mas_equalTo(1);
        }];
        
        [undoLayout mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(lineView.mas_top);
            make.height.mas_equalTo(25);
        }];
        
        [undoDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(undoLayout.mas_left).offset(15);
            make.centerY.equalTo(undoLayout.mas_centerY);
        }];
        
        [self.undoBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(undoLayout.mas_right).offset(-15);
            make.centerY.equalTo(undoLayout.mas_centerY);
            make.width.mas_equalTo(50);
            make.height.equalTo(undoLayout.mas_height);
        }];
        
        [self.effectProgressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15);
            make.bottom.equalTo(undoLayout.mas_top).offset(-15);
            make.right.equalTo(self.mas_right).offset(-15);
            make.height.mas_equalTo(29);
        }];
        
        [self.preview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.bottom.equalTo(self.effectProgressView.mas_top).offset(-17);
            make.width.equalTo(self.mas_width);
            make.top.equalTo(self.mas_top).offset(66);
        }];
    }
    return self;
}

#pragma mark - button target
- (void)onBackBtClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectViewBack)]) {
        [self.delegate effectViewBack];
    }
}

- (void)undoBtClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectViewUndo)]) {
        [self.delegate effectViewUndo];
    }
}

#pragma mark - AYEffectProgressViewDelegate 特效时间进度的回调
- (void)effectProgressViewSeekTo:(CGFloat)progress{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectViewSeekTo:)]) {
        [self.delegate effectViewSeekTo:progress];
    }
}

#pragma mark - AYEffectSelectorViewDelegate 特效选择器的回调
- (void)effectSelectorViewTouchDownModel:(EffectCellModel *)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectViewTouchDownModel:)]) {
        [self.delegate effectViewTouchDownModel:model];
    }
    
    [self.undoBt setHidden:YES];
}

-(void)effectSelectorViewTouchUp{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectViewTouchUp)]) {
        [self.delegate effectViewTouchUp];
    }
    
    [self.undoBt setHidden:NO];
}

#pragma mark - API
- (void)setVideoURL:(NSURL *)videoURL{
    _videoURL = videoURL;
    
    self.effectProgressView.videoURL = videoURL;
}

- (void)setAudioURL:(NSURL *)audioURL{
    _audioURL = audioURL;
    
    self.effectProgressView.audioURL = audioURL;
}

/**
 设置进度
 */
- (void)setProgress:(CGFloat)progress{
    [self.effectProgressView setProgress:progress];
}

/**
 设置特效时长的数据
 */
- (void)setEffectTimeArr:(NSArray<EffectTimeModel *> *)effectTimeArr{
    _effectTimeArr = effectTimeArr;
    
    [self.effectProgressView setEffectTimeArr:effectTimeArr];
}

/**
 设置特效选择器的数据
 */
- (void)setSelectorDataArr:(NSArray<EffectCellModel *> *)selectorDataArr{
    _selectorDataArr = selectorDataArr;
    
    [self.effectSelectorView setSelectorDataArr:selectorDataArr];
}

@end
