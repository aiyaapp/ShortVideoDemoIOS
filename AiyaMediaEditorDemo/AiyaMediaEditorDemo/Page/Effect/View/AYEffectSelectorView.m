//
//  AYEffectSelectorView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/6.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYEffectSelectorView.h"

#import "UIButton+ImageWithLable.h"
#import <Masonry/Masonry.h>

@interface AYEffectSelectorView ()

@property (nonatomic, strong) UIView *containerView;

@end

@implementation AYEffectSelectorView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.showsHorizontalScrollIndicator = YES;

    _containerView = [UIView new];
    
    [self addSubview:scrollView];
    [scrollView addSubview:self.containerView];
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(scrollView);
        // 确定containerView的高度
        make.height.equalTo(scrollView);
    }];
}

#pragma mark - API
- (void)setSelectorDataArr:(NSArray<EffectCellModel *> *)selectorDataArr{
    _selectorDataArr = selectorDataArr;
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    UIButton *bt;
    
    for (int x = 0; x < selectorDataArr.count; x++) {
        
        EffectCellModel *model = [selectorDataArr objectAtIndex:x];
        
        // 加入特效编辑按钮
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setVerticalBtWithImage:[UIImage imageWithContentsOfFile:model.model.thumbnail] withTitle:model.model.text font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:2];
        [button setContentMode:UIViewContentModeScaleAspectFill];
        [button setTag:x];
        [button addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [button addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchCancel];
        
        
        [self.containerView addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(self.containerView.mas_height);
            make.width.equalTo(self.mas_width).multipliedBy(0.2);
            make.top.equalTo(self.containerView.mas_top);
            
            if (x == 0) {
                make.left.equalTo(self.containerView.mas_left);
            } else {
                make.left.equalTo(bt.mas_right);
            }
            
            if (x == selectorDataArr.count - 1) {
                make.right.equalTo(self.containerView.mas_right);
            }
        }];
        
        bt = button;
    }
}

#pragma mark - Button Target
- (void)touchDown:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectSelectorViewTouchDownModel:)]) {
        EffectCellModel *model = [self.selectorDataArr objectAtIndex:bt.tag];
        [self.delegate effectSelectorViewTouchDownModel:model];
    }
    
    for (UIButton *button in [self.containerView subviews]) {
        if (button == bt) {
            continue;
        }else {
            [button setEnabled:NO];
        }
    }
}

- (void)touchUp:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectSelectorViewTouchUp)]) {
        [self.delegate effectSelectorViewTouchUp];
    }
    
    for (UIButton *button in [self.containerView subviews]) {
        if (button == bt) {
            continue;
        }else {
            [button setEnabled:YES];
        }
    }
}

@end
