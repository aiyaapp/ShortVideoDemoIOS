//
//  InputViewController.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "InputViewController.h"
#import "InputView.h"
#import "RecordViewController.h"

#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>

@interface InputViewController () <InputViewDelegate>

@property (nonatomic, strong) InputView *inputView;

@end

@implementation InputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _inputView = [[InputView alloc] init];
    self.inputView.delegate = self;
    
    [self.view addSubview:self.inputView];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    // 请求相机 和 麦克风的权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            NSLog(@"相机权限请求成功");
        } else {
            NSLog(@"相机权限请求失败");
        }
    }];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
        if (granted) {
            NSLog(@"麦克风限请求成功");
        } else {
            NSLog(@"麦克风限请求失败");
        }
    }];
}

#pragma mark - InputViewDelegate
- (void)inputViewSelectVideo{
    NSLog(@"本地导入");
    
    
}

- (void)inputViewStartRecord{
    NSLog(@"开始录制");
    
    NSLog(@"resolution : %@",self.inputView.resolution);
    NSLog(@"frameRate : %@",self.inputView.frameRate);
    NSLog(@"videoBitrate : %@",self.inputView.videoBitrate);
    NSLog(@"audioBitrate : %@",self.inputView.audioBitrate);
    
    RecordViewController *recordVC = [[RecordViewController alloc] init];
    recordVC.resolution = self.inputView.resolution;
    recordVC.frameRate = self.inputView.frameRate;
    recordVC.videoBitrate = self.inputView.videoBitrate;
    recordVC.audioBitrate = self.inputView.audioBitrate;
    
    [self.navigationController pushViewController:recordVC animated:YES];
}

@end
