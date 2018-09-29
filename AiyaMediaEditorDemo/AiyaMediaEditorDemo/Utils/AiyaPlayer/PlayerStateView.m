//
//  PlayerStateView.m
//  aiya
//
//  Created by 汪洋 on 16/8/6.
//  Copyright © 2016年 aiya. All rights reserved.
//

#import "PlayerStateView.h"

@interface PlayerStateView()

@property (nonatomic, strong) UIButton *stopBt;

@end

@implementation PlayerStateView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    
    //暂停
    _stopBt = [[UIButton alloc]init];
    [self.stopBt setContentMode:UIViewContentModeCenter];
    [self.stopBt addTarget:self action:@selector(onStopBtClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.stopBt];
    
    // 使用autoLayout约束，禁止将AutoresizingMask转换为约束
    [self.stopBt setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    {
        NSLayoutConstraint *constraint1 = [NSLayoutConstraint constraintWithItem:self.stopBt attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint2 = [NSLayoutConstraint constraintWithItem:self.stopBt attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint3 = [NSLayoutConstraint constraintWithItem:self.stopBt attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *constraint4 = [NSLayoutConstraint constraintWithItem:self.stopBt attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSArray *array = [NSArray arrayWithObjects:constraint1, constraint2, constraint3, constraint4 ,nil];
        [self addConstraints:array];
    }
}

- (void)onStopBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerStateViewOnStopBtClick)]) {
        [self.delegate playerStateViewOnStopBtClick];
    }
}

#pragma mark API
- (void)setHiddenStopBt{
    [self.stopBt setImage:nil forState:UIControlStateNormal];
}

- (void)setShowStopBt{
    [self.stopBt setImage:[UIImage imageNamed:@"pic_pause"] forState:UIControlStateNormal];
}

@end
