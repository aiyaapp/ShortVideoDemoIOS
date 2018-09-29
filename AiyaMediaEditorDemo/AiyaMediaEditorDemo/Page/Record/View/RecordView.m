//
//  RecordView.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "RecordView.h"
#import "AYRecordSpeedRadioButton.h"
#import "AYRecordProgressView.h"
#import "AYRecordStylePlane.h"
#import "AYRecordFaceEffectPlane.h"
#import "UIButton+ImageWithLable.h"

#import "FaceEffectData.h"
#import "StyleData.h"

#import <Masonry/Masonry.h>

static const NSUInteger contentTag = 1;

static const NSUInteger recordTag = 2;

@interface RecordView () <AYRecordStylePlaneDelegate, AYRecordFaceEffectPlaneDelegate>

@property (nonatomic, strong) UIView *cameraPreview;

@property (nonatomic, strong) AYRecordStylePlane *stylePlane;

@property (nonatomic, strong) AYRecordFaceEffectPlane *faceEffectPlane;

@property (nonatomic, strong) AYRecordSpeedRadioButton *speedRadioBt;

@property (nonatomic, strong) AYRecordProgressView *progressView;

@property (nonatomic, strong) UIButton *recordBt;

@property (nonatomic, strong) UIButton *beautyBt;

@end

@implementation RecordView

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
    
    _cameraPreview = [[UIView alloc] init];
    
    UIButton *backBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBt setImage:[UIImage imageNamed:@"btn_return_n"] forState:UIControlStateNormal];
    [backBt setImage:[UIImage imageNamed:@"btn_return_p"] forState:UIControlStateHighlighted];
    [backBt addTarget:self action:@selector(onBackBtClick:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *switchCameraBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [switchCameraBt setImage:[UIImage imageNamed:@"btn_toggle_n"] forState:UIControlStateNormal];
    [switchCameraBt setImage:[UIImage imageNamed:@"btn_toggle_p"] forState:UIControlStateHighlighted];
    [switchCameraBt addTarget:self action:@selector(onSwitchCameraBtClick:) forControlEvents:UIControlEventTouchUpInside];

    UIView *containerView = [UIView new];
    
    UIButton *nextBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextBt setTitle:@"下一步" forState:UIControlStateNormal];
    [nextBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [nextBt addTarget:self action:@selector(onNextBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *styleBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [styleBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_filter_n"] withTitle:@"滤镜" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [styleBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_filter_p"] withTitle:@"滤镜" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateHighlighted padding:5];
    [styleBt addTarget:self action:@selector(onStyleBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    _beautyBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_skin care_n"] withTitle:@"美颜关" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [self.beautyBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_skin care_p"] withTitle:@"美颜开" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateSelected padding:5];
    [self.beautyBt addTarget:self action:@selector(onBeautyBtClick:) forControlEvents:UIControlEventTouchUpInside];

    _speedRadioBt = [[AYRecordSpeedRadioButton alloc] init];
    [self.speedRadioBt setSelectedText:@"标准"];
    
    UIView *recordBtLeftLayout = [[UIView alloc] init];
    
    UIButton *faceEffectBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [faceEffectBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_effect of face_n"] withTitle:@"人脸特效" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateNormal padding:5];
    [faceEffectBt setVerticalBtWithImage:[UIImage imageNamed:@"btn_effect of face_p"] withTitle:@"人脸特效" font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] forState:UIControlStateHighlighted padding:5];
    [faceEffectBt addTarget:self action:@selector(onFaceEffectBtClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *progressBg = [UIImageView new];
    [progressBg setImage:[[UIImage imageNamed:@"pic_the progress bar"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeTile]];
    
    _progressView = [[AYRecordProgressView alloc] init];
    
    _recordBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordBt setImage:[UIImage imageNamed:@"btn_luzhi_n"] forState:UIControlStateNormal];
    [self.recordBt setImage:[UIImage imageNamed:@"btn_suspended_n"] forState:UIControlStateSelected];
    [self.recordBt addTarget:self action:@selector(onRecordBtClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBt addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];

    UIView *recordBtRightLayout = [[UIView alloc] init];

    UIButton *removeVideoItemBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeVideoItemBt setImage:[UIImage imageNamed:@"btn_delete_n"] forState:UIControlStateNormal];
    [removeVideoItemBt setImage:[UIImage imageNamed:@"btn_delete_p"] forState:UIControlStateHighlighted];
    [removeVideoItemBt addTarget:self action:@selector(onRemoveVideoItemBtClick:) forControlEvents:UIControlEventTouchUpInside];

    _stylePlane = [[AYRecordStylePlane alloc] init];
    self.stylePlane.dataArr = [StyleData data];
    self.stylePlane.delegate = self;
    [self.stylePlane addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];
    
    _faceEffectPlane = [[AYRecordFaceEffectPlane alloc] init];
    self.faceEffectPlane.dataArr = [FaceEffectData data];
    self.faceEffectPlane.delegate = self;
    [self.faceEffectPlane addObserver:self forKeyPath:@"hidden" options:NSKeyValueObservingOptionNew context:nil];

    // 普通控件
    [backBt setTag:contentTag];
    [switchCameraBt setTag:contentTag];
    [containerView setTag:contentTag];
    [nextBt setTag:contentTag];
    [styleBt setTag:contentTag];
    [self.beautyBt setTag:contentTag];
    [self.speedRadioBt setTag:contentTag];
    [recordBtLeftLayout setTag:contentTag];
    [recordBtRightLayout setTag:contentTag];

    // 录制控件
    [progressBg setTag:recordTag];
    [self.progressView setTag:recordTag];
    [self.recordBt setTag:recordTag];

    [self addSubview:self.cameraPreview];
    [self addSubview:backBt];
    [self addSubview:switchCameraBt];
    [self addSubview:containerView];
    [containerView addSubview:nextBt];
    [containerView addSubview:styleBt];
    [containerView addSubview:self.beautyBt];
    [self addSubview:self.speedRadioBt];
    [self addSubview:recordBtLeftLayout];
    [recordBtLeftLayout addSubview:faceEffectBt];
    [self addSubview:progressBg];
    [self addSubview:self.progressView];
    [self addSubview:self.recordBt];
    [self addSubview:recordBtRightLayout];
    [recordBtRightLayout addSubview:removeVideoItemBt];
    [self addSubview:self.stylePlane];
    [self addSubview:self.faceEffectPlane];
    
    [self.cameraPreview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(0);
    }];
    
    [backBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top).offset(22);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    [switchCameraBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(22);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.width.mas_equalTo(80);
    }];
    
    [nextBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(22);
        make.right.equalTo(self.mas_right).offset(-15);
        make.height.mas_equalTo(44);
    }];
    
    [styleBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(nextBt.mas_bottom).offset(48);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(60);
    }];
    
    [self.beautyBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(styleBt.mas_bottom).offset(25);
        make.right.equalTo(self.mas_right).offset(-10);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(60);
    }];

    [self.speedRadioBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(75);
        make.right.equalTo(self.mas_right).offset(-75);
        make.centerX.equalTo(self.mas_centerX);
        make.bottom.equalTo(self.progressView.mas_top).offset(-35);
        make.height.mas_equalTo(30);
    }];
    
    [recordBtLeftLayout mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.recordBt.mas_left);
        make.top.equalTo(self.recordBt.mas_top);
        make.bottom.equalTo(self.recordBt.mas_bottom);
    }];
    
    [faceEffectBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(recordBtLeftLayout.mas_centerX);
        make.centerY.equalTo(recordBtLeftLayout.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
    }];
    
    [progressBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.progressView.mas_left);
        make.right.equalTo(self.progressView.mas_right);
        make.centerY.equalTo(self.progressView.mas_centerY);
        make.height.mas_equalTo(3);
    }];
    
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.recordBt.mas_top).offset(-30);
        make.right.equalTo(self.mas_right);
        make.height.mas_equalTo(10);
    }];
    
    [self.recordBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(60);
        make.height.mas_equalTo(60);
        make.bottom.equalTo(self.mas_bottom).offset(-20);
    }];
    
    [recordBtRightLayout mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.recordBt.mas_right);
        make.right.equalTo(self.mas_right);
        make.top.equalTo(self.recordBt.mas_top);
        make.bottom.equalTo(self.recordBt.mas_bottom);
    }];
    
    [removeVideoItemBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(recordBtRightLayout.mas_centerX);
        make.centerY.equalTo(recordBtRightLayout.mas_centerY);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(50);
    }];
    
    [self.stylePlane mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.faceEffectPlane mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - Button Target
- (void)onBackBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewBack)]) {
        [self.delegate recordViewBack];
    }
}

- (void)onSwitchCameraBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewSwitchCamera)]) {
        [self.delegate recordViewSwitchCamera];
    }
}

- (void)onNextBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewNext)]) {
        [self.delegate recordViewNext];
    }
}

- (void)onBeautyBtClick:(UIButton *)bt{
    if (!bt.isSelected) {
        bt.selected = !bt.isSelected;
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewBeauty:)]) {
            [self.delegate recordViewBeauty:YES];
        }
    }else {
        bt.selected = !bt.isSelected;
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewBeauty:)]) {
            [self.delegate recordViewBeauty:NO];
        }
    }
}

- (void)onStyleBtClick:(UIButton *)bt{
    [self.stylePlane hideUseAnim:NO];
}

- (void)onFaceEffectBtClick:(UIButton *)bt{
    [self.faceEffectPlane hideUseAnim:NO];
}

- (void)onRecordBtClick:(UIButton *)bt{
    if (!bt.isSelected) {
        bt.selected = !bt.isSelected;
        if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewStartRecord)]) {
            [self.delegate recordViewStartRecord];
        }
    }else {
        bt.selected = !bt.isSelected;

        if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewStopRecord)]) {
            [self.delegate recordViewStopRecord];
        }
    }
}

- (void)onRemoveVideoItemBtClick:(UIButton *)bt{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewDelete)]) {
        [self.delegate recordViewDelete];
    }
}

#pragma mark - AYRecordStylePlaneDelegate
- (void)recordStylePlaneSelectedModel:(StyleModel *)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewStyle:)]) {
        [self.delegate recordViewStyle:model];
    }
}

#pragma mark - AYRecordFaceEffectPlaneDelegate
- (void)recordFaceEffectPlaneSelectedModel:(FaceEffectModel *)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordViewFaceEffect:)]) {
        [self.delegate recordViewFaceEffect:model];
    }
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.stylePlane || object == self.faceEffectPlane) {
        BOOL hidden = [change[NSKeyValueChangeNewKey] boolValue];
        for (UIView *view in self.subviews){
            if (view.tag == contentTag || view.tag == recordTag) {
                [view setHidden:!hidden];
            }
        }
    } else if (object == self.recordBt){
        BOOL selected = [change[NSKeyValueChangeNewKey] boolValue];
        for (UIView *view in self.subviews){
            if (view.tag == contentTag) {
                [view setHidden:selected];
            }
        }
    }
}

#pragma mark - API
- (void)clickRecordBt{
    [self onRecordBtClick:self.recordBt];
}

- (void)deselectBeautyBt{
    [self.beautyBt setSelected:NO];
}

- (void)dealloc{
    [self.stylePlane removeObserver:self forKeyPath:@"hidden"];
    [self.faceEffectPlane removeObserver:self forKeyPath:@"hidden"];
    [self.recordBt removeObserver:self forKeyPath:@"selected"];
}

@end
