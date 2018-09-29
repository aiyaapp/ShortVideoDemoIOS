//
//  OutputView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "OutputView.h"
#import <Masonry/Masonry.h>
#import "AYRadioButton.h"

@interface OutputView ()

@property (nonatomic, strong) AYRadioButton *resolutionRadioBt;
@property (nonatomic, strong) AYRadioButton *videoBitrateRadioBt;
@property (nonatomic, strong) AYRadioButton *audioBitrateRadioBt;

@end

@implementation OutputView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.backgroundColor = [UIColor blackColor];
    
    UIButton *backBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBt setImage:[UIImage imageNamed:@"btn_return_n"] forState:UIControlStateNormal];
    [backBt setImage:[UIImage imageNamed:@"btn_return_p"] forState:UIControlStateHighlighted];
    [backBt addTarget:self action:@selector(onBackBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.text = @"保存参数";
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont systemFontOfSize:18];
    titleLable.textAlignment = NSTextAlignmentCenter;
    
    UILabel *resolutionLable = [[UILabel alloc] init];
    resolutionLable.text = @"分辨率";
    resolutionLable.font = [UIFont systemFontOfSize:14];
    resolutionLable.textColor = [UIColor grayColor];
    
    _resolutionRadioBt = [[AYRadioButton alloc] initWithTexts:@[@"540p",@"720p",@"1080p"]];
    [self.resolutionRadioBt setSelectedText:@"720p"];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor grayColor];
    
    UILabel *videoBitrateLable = [[UILabel alloc] init];
    videoBitrateLable.text = @"视频码率\n(kbps)";
    videoBitrateLable.font = [UIFont systemFontOfSize:14];
    videoBitrateLable.textColor = [UIColor grayColor];
    videoBitrateLable.numberOfLines = 2;
    
    _videoBitrateRadioBt = [[AYRadioButton alloc] initWithTexts:@[@"2048",@"4096",@"8192"]];
    [self.videoBitrateRadioBt setSelectedText:@"4096"];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = [UIColor grayColor];
    
    UILabel *audioBitrateLable = [[UILabel alloc] init];
    audioBitrateLable.text = @"音频帧率\n(kbps)";
    audioBitrateLable.font = [UIFont systemFontOfSize:14];
    audioBitrateLable.textColor = [UIColor grayColor];
    audioBitrateLable.numberOfLines = 2;
    
    _audioBitrateRadioBt = [[AYRadioButton alloc] initWithTexts:@[@"64",@"128",@"256"]];
    [self.audioBitrateRadioBt setSelectedText:@"128"];
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = [UIColor grayColor];

    UIButton *saveBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBt setTitle:@"保存到相册" forState:UIControlStateNormal];
    [saveBt setTitleColor:[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1/1.0] forState:UIControlStateNormal];
    [saveBt addTarget:self action:@selector(onSaveBtClick:) forControlEvents:UIControlEventTouchUpInside];
    [saveBt setBackgroundColor:[UIColor colorWithRed:254/255.0 green:112/255.0 blue:68/255.0 alpha:1/1.0]];
    
    [self addSubview:backBt];
    [self addSubview:titleLable];
    [self addSubview:resolutionLable];
    [self addSubview:self.resolutionRadioBt];
    [self addSubview:line];
    [self addSubview:videoBitrateLable];
    [self addSubview:self.videoBitrateRadioBt];
    [self addSubview:line1];
    [self addSubview:audioBitrateLable];
    [self addSubview:self.audioBitrateRadioBt];
    [self addSubview:line2];
    [self addSubview:saveBt];
    
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
    
    [resolutionLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.top.equalTo(titleLable.mas_bottom);
        make.width.equalTo(self.mas_width).multipliedBy(0.26);
        make.height.mas_equalTo(45);
    }];
    
    [self.resolutionRadioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(resolutionLable.mas_right);
        make.top.equalTo(resolutionLable.mas_top);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(resolutionLable.mas_bottom);
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(resolutionLable.mas_left);
        make.right.equalTo(self.resolutionRadioBt.mas_right);
        make.top.equalTo(resolutionLable.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [videoBitrateLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.top.equalTo(resolutionLable.mas_bottom);
        make.width.equalTo(self.mas_width).multipliedBy(0.26);
        make.height.mas_equalTo(45);
    }];
    
    [self.videoBitrateRadioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoBitrateLable.mas_right);
        make.top.equalTo(videoBitrateLable.mas_top);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(videoBitrateLable.mas_bottom);
    }];
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoBitrateLable.mas_left);
        make.right.equalTo(self.videoBitrateRadioBt.mas_right);
        make.top.equalTo(videoBitrateLable.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [audioBitrateLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.top.equalTo(videoBitrateLable.mas_bottom);
        make.width.equalTo(self.mas_width).multipliedBy(0.26);
        make.height.mas_equalTo(45);
    }];
    
    [self.audioBitrateRadioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(audioBitrateLable.mas_right);
        make.top.equalTo(audioBitrateLable.mas_top);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(audioBitrateLable.mas_bottom);
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(audioBitrateLable.mas_left);
        make.right.equalTo(self.audioBitrateRadioBt.mas_right);
        make.top.equalTo(audioBitrateLable.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [saveBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(48);
        make.right.equalTo(self.mas_right).offset(-48);
        make.bottom.equalTo(self.mas_bottom).offset(-30);
        make.height.mas_equalTo(40);
    }];
}

- (void)setResolution:(NSString *)resolution{
    [self.resolutionRadioBt setSelectedText:resolution];
}

- (NSString *)resolution{
    return [self.resolutionRadioBt selectedText];
}

- (void)setVideoBitrate:(NSString *)videoBitrate{
    [self.videoBitrateRadioBt setSelectedText:videoBitrate];
}

- (NSString *)videoBitrate{
    return [self.videoBitrateRadioBt selectedText];
}

- (void)setAudioBitrate:(NSString *)audioBitrate{
    [self.audioBitrateRadioBt setSelectedText:audioBitrate];
}

- (NSString *)audioBitrate{
    return [self.audioBitrateRadioBt selectedText];
}

#pragma mark button target
- (void)onBackBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(outputViewBack)]) {
        [self.delegate outputViewBack];
    }
}

- (void)onSaveBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(outputViewSaveVideo)]) {
        [self.delegate outputViewSaveVideo];
    }
}
@end
