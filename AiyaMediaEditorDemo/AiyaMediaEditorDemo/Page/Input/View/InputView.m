//
//  InputView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "InputView.h"
#import "AYRadioButton.h"
#import "UIButton+ImageWithLable.h"

#import <Masonry/Masonry.h>

@interface InputView ()

@property (nonatomic, strong) AYRadioButton *resolutionRadioBt;
@property (nonatomic, strong) AYRadioButton *frameRateRadioBt;
@property (nonatomic, strong) AYRadioButton *videoBitrateRadioBt;
@property (nonatomic, strong) AYRadioButton *audioBitrateRadioBt;

@end

@implementation InputView

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
    
    UILabel *titleLable = [[UILabel alloc] init];
    titleLable.text = @"录制参数";
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
    
    UILabel *frameRateLable = [[UILabel alloc] init];
    frameRateLable.text = @"帧率(fps)";
    frameRateLable.font = [UIFont systemFontOfSize:14];
    frameRateLable.textColor = [UIColor grayColor];
    
    _frameRateRadioBt = [[AYRadioButton alloc] initWithTexts:@[@"15",@"24",@"30"]];
    [self.frameRateRadioBt setSelectedText:@"30"];
    
    UIView *line1 = [UIView new];
    line1.backgroundColor = [UIColor grayColor];
    
    UILabel *videoBitrateLable = [[UILabel alloc] init];
    videoBitrateLable.text = @"视频码率\n(kbps)";
    videoBitrateLable.font = [UIFont systemFontOfSize:14];
    videoBitrateLable.textColor = [UIColor grayColor];
    videoBitrateLable.numberOfLines = 2;
    
    _videoBitrateRadioBt = [[AYRadioButton alloc] initWithTexts:@[@"2048",@"4096",@"8192"]];
    [self.videoBitrateRadioBt setSelectedText:@"4096"];
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = [UIColor grayColor];
    
    UILabel *audioBitrateLable = [[UILabel alloc] init];
    audioBitrateLable.text = @"音频帧率\n(kbps)";
    audioBitrateLable.font = [UIFont systemFontOfSize:14];
    audioBitrateLable.textColor = [UIColor grayColor];
    audioBitrateLable.numberOfLines = 2;

    _audioBitrateRadioBt = [[AYRadioButton alloc] initWithTexts:@[@"64",@"128",@"256"]];
    [self.audioBitrateRadioBt setSelectedText:@"64"];

    UIView *line3 = [UIView new];
    line3.backgroundColor = [UIColor grayColor];
    
    UIButton *selectVideoBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectVideoBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_the import_n"] withTitle:@"本地导入" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:10];
    [selectVideoBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_the import_p"] withTitle:@"本地导入" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateHighlighted padding:10];
    [selectVideoBt addTarget:self action:@selector(onSelectVideoBtClick:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *recordBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [recordBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_shooting_n"] withTitle:@"开始录制" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:10];
    [recordBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_shooting_p"] withTitle:@"开始录制" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateHighlighted padding:10];
    [recordBt addTarget:self action:@selector(onRecordBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:titleLable];
    [self addSubview:resolutionLable];
    [self addSubview:self.resolutionRadioBt];
    [self addSubview:line];
    [self addSubview:frameRateLable];
    [self addSubview:self.frameRateRadioBt];
    [self addSubview:line1];
    [self addSubview:videoBitrateLable];
    [self addSubview:self.videoBitrateRadioBt];
    [self addSubview:line2];
    [self addSubview:audioBitrateLable];
    [self addSubview:self.audioBitrateRadioBt];
    [self addSubview:line3];
    [self addSubview:selectVideoBt];
    [self addSubview:recordBt];
    
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
    
    [frameRateLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.top.equalTo(resolutionLable.mas_bottom);
        make.width.equalTo(self.mas_width).multipliedBy(0.26);
        make.height.mas_equalTo(45);
    }];
    
    [self.frameRateRadioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(frameRateLable.mas_right);
        make.top.equalTo(frameRateLable.mas_top);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(frameRateLable.mas_bottom);
    }];
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(frameRateLable.mas_left);
        make.right.equalTo(self.frameRateRadioBt.mas_right);
        make.top.equalTo(frameRateLable.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [videoBitrateLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.top.equalTo(frameRateLable.mas_bottom);
        make.width.equalTo(self.mas_width).multipliedBy(0.26);
        make.height.mas_equalTo(45);
    }];
    
    [self.videoBitrateRadioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(videoBitrateLable.mas_right);
        make.top.equalTo(videoBitrateLable.mas_top);
        make.right.equalTo(self.mas_right).offset(-15);
        make.bottom.equalTo(videoBitrateLable.mas_bottom);
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
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
    
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(audioBitrateLable.mas_left);
        make.right.equalTo(self.audioBitrateRadioBt.mas_right);
        make.top.equalTo(audioBitrateLable.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    [selectVideoBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom).offset(-30);
        make.width.equalTo(self.mas_width).multipliedBy(0.5);
    }];
    
    [recordBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom).offset(-30);
        make.width.equalTo(self.mas_width).multipliedBy(0.5);
    }];
}

- (void)setResolution:(NSString *)resolution{
    [self.resolutionRadioBt setSelectedText:resolution];
}

- (NSString *)resolution{
    return [self.resolutionRadioBt selectedText];
}

- (void)setFrameRate:(NSString *)frameRate{
    [self.frameRateRadioBt setSelectedText:frameRate];
}

- (NSString *)frameRate{
    return [self.frameRateRadioBt selectedText];
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
- (void)onSelectVideoBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewSelectVideo)]) {
        [self.delegate inputViewSelectVideo];
    }
}

- (void)onRecordBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputViewStartRecord)]) {
        [self.delegate inputViewStartRecord];
    }
}

@end
