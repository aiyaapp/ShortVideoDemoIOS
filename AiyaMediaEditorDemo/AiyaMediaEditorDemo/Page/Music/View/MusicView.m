//
//  MusicView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/9.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "MusicView.h"
#import "MusicCellView.h"
#import "AppDelegate.h"

#import <Masonry/Masonry.h>

@interface MusicView () <MusicCellViewDelegate>

@property (nonatomic, strong) UIView *containerView;

@end

@implementation MusicView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        UIButton *backBt = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBt setImage:[UIImage imageNamed:@"btn_return_n"] forState:UIControlStateNormal];
        [backBt setImage:[UIImage imageNamed:@"btn_return_p"] forState:UIControlStateHighlighted];
        [backBt addTarget:self action:@selector(onBackBtClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *titleLable = [[UILabel alloc] init];
        titleLable.text = @"音乐";
        titleLable.textColor = [UIColor whiteColor];
        titleLable.font = [UIFont systemFontOfSize:18];
        titleLable.textAlignment = NSTextAlignmentCenter;
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsVerticalScrollIndicator = YES;
        
        _containerView = [UIView new];
        
        [self addSubview:backBt];
        [self addSubview:titleLable];
        [self addSubview:scrollView];
        [scrollView addSubview:self.containerView];
        
        [backBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top).offset(22);
            make.width.mas_equalTo(44);
            make.height.mas_equalTo(44);
        }];
        
        [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(self.mas_top).offset(22);
            make.width.mas_equalTo(self.mas_width);
            make.height.mas_equalTo(44);
        }];
        
        [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(15);
            make.top.equalTo(titleLable.mas_bottom);
            make.right.equalTo(self.mas_right).offset(-15);
            make.bottom.equalTo(self.mas_bottom);
        }];
        
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(scrollView);
            // 确定containerView的高度
            make.width.equalTo(scrollView);
        }];
    }
    return self;
}

- (void)setMusicDataArr:(NSArray<MusicModel *> *)musicDataArr{
    _musicDataArr = musicDataArr;
    
    for (UIView *view in self.containerView.subviews) {
        [view removeFromSuperview];
    }
    
    UIView *lastView;
    
    MusicCellView *selectedView;
    
    for (int x = 0; x < musicDataArr.count; x++) {
        
        MusicModel *model = [musicDataArr objectAtIndex:x];
        
        MusicCellView *cellView = [MusicCellView new];
        cellView.delegate = self;
        cellView.model = model;

        [self.containerView addSubview:cellView];
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (delegate.musicName == nil && [model.musicName isEqualToString:@"无"]) {
            selectedView = cellView;
        }else if([delegate.musicName isEqualToString:model.musicName]) {
            selectedView = cellView;
        }
        
        [cellView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.containerView.mas_width);
            make.height.mas_equalTo(55);
            make.left.equalTo(self.containerView.mas_left);
            
            if (x == 0) {
                make.top.equalTo(self.containerView.mas_top);
            } else {
                make.top.equalTo(lastView.mas_bottom);
            }
            
            if (x == musicDataArr.count - 1) {
                make.bottom.equalTo(self.containerView.mas_bottom);
            }
        }];
        
        lastView = cellView;
    }
    
    [self musicCellViewOnClick:selectedView];
}

#pragma mark - API
- (void)onBackBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicViewOnBack)]) {
        [self.delegate musicViewOnBack];
    }
}


#pragma mark - MusicCellViewDelegate
- (void)musicCellViewOnClick:(MusicCellView *)view{
    NSArray<UIView *> *subviews = [self.containerView subviews];
    
    for (id subview in subviews) {
        MusicCellView *cellView = subview;
        [cellView setSelected:view == cellView];
    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.musicName = view.model.musicName;
    delegate.musicPath = view.model.musicPath;
    
    if (view && self.delegate && [self.delegate respondsToSelector:@selector(musicViewOnItemClick:)]) {
        [self.delegate musicViewOnItemClick:view.model];
    }
}


@end
