//
//  AYRecordPlaneCollectionViewCell.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/24.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYRecordPlaneCollectionViewCell.h"

#import <Masonry/Masonry.h>

@interface AYRecordPlaneCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation AYRecordPlaneCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    _imageView = [[UIImageView alloc] init];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    _label = [[UILabel alloc] init];
    [self.label setFont:[UIFont systemFontOfSize:14]];
    [self.label setTextColor:[UIColor whiteColor]];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.label];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(5);
        make.right.equalTo(self.contentView.mas_right).offset(-5);
        make.top.equalTo(self.contentView.mas_top);
        make.bottom.equalTo(self.label.mas_top);
    }];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-5);
        make.right.equalTo(self.contentView.mas_right);
        make.height.mas_equalTo(25);
    }];
}

- (void)setThumbnail:(NSString *)thumbnail{
    _thumbnail = thumbnail;
    
    [self.imageView setImage:[UIImage imageNamed:thumbnail]];
}

- (void)setText:(NSString *)text{
    _text = text;
    
    [self.label setText:text];
}

@end
