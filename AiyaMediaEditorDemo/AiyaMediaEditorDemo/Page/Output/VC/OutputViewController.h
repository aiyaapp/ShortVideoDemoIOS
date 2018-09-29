//
//  OutputViewController.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OutputViewController : UIViewController

@property (nonatomic, strong) NSString *videoPath;

@property (nonatomic, strong) NSString *audioPath;

@property (nonatomic, strong) UIImage *waterMaskImage;

@property (nonatomic, assign) CGSize waterMaskSize;

@property (nonatomic, assign) CGPoint waterMaskPosition;

@property (nonatomic, assign) CGFloat audioVolume;

@property (nonatomic, strong) NSString *musicPath;

@property (nonatomic, assign) CGFloat musicVolume;

@property (nonatomic, assign) CGFloat musicStartTime;

@end
