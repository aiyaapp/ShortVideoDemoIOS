//
//  MusicCellView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/9.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "MusicCellView.h"
#import "UIButton+ImageWithLable.h"

#import <Masonry/Masonry.h>

@interface MusicCellView ()

@property (nonatomic, strong) UIImageView *arrowIv;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *button;

@end

@implementation MusicCellView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _arrowIv = [UIImageView new];
        [self.arrowIv setImage:[UIImage imageNamed:@"icon_selected"]];
        
        _nameLabel = [UILabel new];
        [self.nameLabel setFont:[UIFont systemFontOfSize:14]];
        [self.nameLabel setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0]];

        _timeLabel = [UILabel new];
        [self.timeLabel setFont:[UIFont systemFontOfSize:14]];
        [self.timeLabel setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0]];

        UIView *lineView = [UIView new];
        [lineView setBackgroundColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0]];
        
        [self addSubview:self.arrowIv];
        [self addSubview:self.nameLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:lineView];
        [self addSubview:self.button];

        [self.arrowIv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.width.mas_equalTo(14);
            make.height.mas_equalTo(14);
            make.centerY.equalTo(self.mas_centerY);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.arrowIv.mas_right).offset(11);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.width.mas_equalTo(220);
        }];
        
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.width.mas_equalTo(60);
        }];
        
        [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(self.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return self;
}

- (void)setModel:(MusicModel *)model{
    _model = model;
    
    [self.nameLabel setText:model.musicName];
    
    [self.timeLabel setText:[NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)model.musicDuration / 60, (NSInteger)model.musicDuration % 60]];
}

- (void)onButtonClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicCellViewOnClick:)]) {
        [self.delegate musicCellViewOnClick:self];
    }
}

- (void)setSelected:(BOOL)selected{
    _selected = selected;
    
    if (selected) {
        // 如果打上了勾
        [self.arrowIv setHidden:NO];
        [self.nameLabel setTextColor:[UIColor colorWithRed:254/255.0 green:112/255.0 blue:68/255.0 alpha:1/1.0]];
    } else {
        [self.arrowIv setHidden:YES];
        [self.nameLabel setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0]];
    }
}

@end
