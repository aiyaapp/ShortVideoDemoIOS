//
//  AYEditMixAudioView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/2.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AYEditMixAudioViewDelegate <NSObject>
@optional

- (void)editMixAudioViewUpdateRecordAudioVolume:(CGFloat)recordAudioVolume musicVolume:(CGFloat)musicVolume;

- (void)editMixAudioViewUpdateFinish;

@end

@interface AYEditMixAudioView : UIView

@property (nonatomic, weak) id<AYEditMixAudioViewDelegate> delegate;

@property (nonatomic, assign) CGFloat recordAudioVolume;

@property (nonatomic, assign) CGFloat musicVolume;

@end
