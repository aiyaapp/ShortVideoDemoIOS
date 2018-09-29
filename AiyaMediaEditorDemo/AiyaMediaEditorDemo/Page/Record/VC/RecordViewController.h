//
//  RecordViewController.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordViewController : UIViewController

/**
 分辩率在录制的时候设置
 */
@property (nonatomic, strong) NSString *resolution;

/**
 帧率在最后合成的时候设置
 */
@property (nonatomic, strong) NSString *frameRate;

/**
 视频码率在合成的时候设置
 */
@property (nonatomic, strong) NSString *videoBitrate;

/**
 音频码率在合成的时候设置
 */
@property (nonatomic, strong) NSString *audioBitrate;

@end
