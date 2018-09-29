//
//  InputView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputViewDelegate <NSObject>
@optional

- (void)inputViewSelectVideo;

- (void)inputViewStartRecord;

@end

@interface InputView : UIView

@property (nonatomic, strong) NSString *resolution;
@property (nonatomic, strong) NSString *frameRate;
@property (nonatomic, strong) NSString *videoBitrate;
@property (nonatomic, strong) NSString *audioBitrate;

@property (nonatomic, weak) id<InputViewDelegate> delegate;

@end
