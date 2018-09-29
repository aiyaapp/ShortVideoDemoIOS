//
//  AYEditMixAudioView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/2.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYEditMixAudioView.h"

#import <Masonry/Masonry.h>

@interface AYEditMixAudioView ()

@property (nonatomic, strong) UISlider *mainVolumeSlider;

@property (nonatomic, strong) UISlider *deputyVolumeSlider;

@end

@implementation AYEditMixAudioView

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *mainVolumeLayout = [[UIView alloc] init];
        mainVolumeLayout.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

        UILabel *mainLabel = [[UILabel alloc] init];
        mainLabel.text = @"视频原声";
        mainLabel.font = [UIFont systemFontOfSize:14];
        mainLabel.textColor = [UIColor whiteColor];
        
        _mainVolumeSlider = [[UISlider alloc] init];
        self.mainVolumeSlider.minimumValue = 0;
        self.mainVolumeSlider.maximumValue = 1.8;
        self.mainVolumeSlider.value = 1;
        self.mainVolumeSlider.minimumTrackTintColor = [UIColor colorWithRed:254/255.0 green:112/255.0 blue:68/255.0 alpha:1/1.0];
        self.mainVolumeSlider.maximumTrackTintColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        [self.mainVolumeSlider setThumbImage:[UIImage imageNamed:@"btn"] forState:UIControlStateNormal];
        [self.mainVolumeSlider addTarget:self action:@selector(onMainVolumeValueChange:) forControlEvents:UIControlEventValueChanged];
        
        UIView *deputyVolumeLayout = [[UIView alloc] init];
        deputyVolumeLayout.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];

        UILabel *deputyLabel = [[UILabel alloc] init];
        deputyLabel.text = @"配乐";
        deputyLabel.font = [UIFont systemFontOfSize:14];
        deputyLabel.textColor = [UIColor whiteColor];
        
        _deputyVolumeSlider = [[UISlider alloc] init];
        self.deputyVolumeSlider.minimumValue = 0;
        self.deputyVolumeSlider.maximumValue = 1.8;
        self.deputyVolumeSlider.value = 1;
        self.deputyVolumeSlider.minimumTrackTintColor = [UIColor colorWithRed:254/255.0 green:112/255.0 blue:68/255.0 alpha:1/1.0];
        self.deputyVolumeSlider.maximumTrackTintColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0];
        [self.deputyVolumeSlider setThumbImage:[UIImage imageNamed:@"btn"] forState:UIControlStateNormal];
        [self.deputyVolumeSlider addTarget:self action:@selector(onDeputyVolumeValueChange:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:button];
        [self addSubview:mainVolumeLayout];
        [mainVolumeLayout addSubview:mainLabel];
        [mainVolumeLayout addSubview:self.mainVolumeSlider];
        [self addSubview:deputyVolumeLayout];
        [deputyVolumeLayout addSubview:deputyLabel];
        [deputyVolumeLayout addSubview:self.deputyVolumeSlider];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.bottom.equalTo(mainVolumeLayout.mas_top);
        }];
        
        [mainVolumeLayout mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(deputyVolumeLayout.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.mas_equalTo(60);
        }];
        
        [mainLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainVolumeLayout.mas_left).offset(15);
            make.centerY.equalTo(mainVolumeLayout.mas_centerY);
            make.width.mas_equalTo(60);
            make.top.equalTo(mainVolumeLayout.mas_top);
            make.bottom.equalTo(mainVolumeLayout.mas_bottom);
        }];
        
        [self.mainVolumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(mainLabel.mas_right).offset(9);
            make.centerY.equalTo(mainVolumeLayout.mas_centerY);
            make.top.equalTo(mainVolumeLayout.mas_top);
            make.bottom.equalTo(mainVolumeLayout.mas_bottom);
            make.right.equalTo(mainVolumeLayout.mas_right).offset(-15);
        }];
        
        [deputyVolumeLayout mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.bottom.equalTo(self.mas_bottom);
            make.right.equalTo(self.mas_right);
            make.height.mas_equalTo(60);
        }];
        
        [deputyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(deputyVolumeLayout.mas_left).offset(15);
            make.centerY.equalTo(deputyVolumeLayout.mas_centerY);
            make.width.mas_equalTo(60);
            make.top.equalTo(deputyVolumeLayout.mas_top);
            make.bottom.equalTo(deputyVolumeLayout.mas_bottom);
        }];
        
        [self.deputyVolumeSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(deputyLabel.mas_right).offset(9);
            make.centerY.equalTo(deputyVolumeLayout.mas_centerY);
            make.top.equalTo(deputyVolumeLayout.mas_top);
            make.bottom.equalTo(deputyVolumeLayout.mas_bottom);
            make.right.equalTo(deputyVolumeLayout.mas_right).offset(-15);
        }];
    }
    return self;
}

- (void)onButtonClick:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editMixAudioViewUpdateFinish)]) {
        [self.delegate editMixAudioViewUpdateFinish];
    }
}

- (void)setRecordAudioVolume:(CGFloat)recordAudioVolume{
    _recordAudioVolume = recordAudioVolume;
    self.mainVolumeSlider.value = recordAudioVolume;
}

- (void)setMusicVolume:(CGFloat)musicVolume{
    _musicVolume = musicVolume;
    self.deputyVolumeSlider.value = musicVolume;
}

- (void)onMainVolumeValueChange:(UISlider *)sliderView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editMixAudioViewUpdateRecordAudioVolume:musicVolume:)]) {
        [self.delegate editMixAudioViewUpdateRecordAudioVolume:self.mainVolumeSlider.value musicVolume:self.deputyVolumeSlider.value];
    }
}

- (void)onDeputyVolumeValueChange:(UISlider *)sliderView{
    if (self.delegate && [self.delegate respondsToSelector:@selector(editMixAudioViewUpdateRecordAudioVolume:musicVolume:)]) {
        [self.delegate editMixAudioViewUpdateRecordAudioVolume:self.mainVolumeSlider.value musicVolume:self.deputyVolumeSlider.value];
    }
}

@end
