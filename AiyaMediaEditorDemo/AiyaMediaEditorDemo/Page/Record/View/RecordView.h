//
//  RecordView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AYRecordStylePlane.h"
#import "AYRecordFaceEffectPlane.h"
#import "AYRecordProgressView.h"
#import "AYRecordSpeedRadioButton.h"
#import "FaceEffectModel.h"
#import "StyleModel.h"

@protocol RecordViewDelegate <NSObject>
@optional

- (void)recordViewBack;

- (void)recordViewSwitchCamera;

- (void)recordViewNext;

- (void)recordViewBeauty:(BOOL)open;

- (void)recordViewStyle:(StyleModel *)model;

- (void)recordViewFaceEffect:(FaceEffectModel *)model;

- (void)recordViewStartRecord;

- (void)recordViewStopRecord;

- (void)recordViewDelete;

@end

@interface RecordView : UIView

@property (nonatomic, weak) id<RecordViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *cameraPreview;

@property (nonatomic, strong, readonly) AYRecordSpeedRadioButton *speedRadioBt;

@property (nonatomic, strong, readonly) AYRecordProgressView *progressView;

@property (nonatomic, strong, readonly) UIButton *recordBt;

- (void)clickRecordBt;

- (void)deselectBeautyBt;

@end
