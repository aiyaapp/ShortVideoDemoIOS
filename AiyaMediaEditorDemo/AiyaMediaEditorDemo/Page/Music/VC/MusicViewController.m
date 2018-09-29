//
//  MusicViewController.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/9.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "MusicViewController.h"
#import "MusicView.h"

#import <Masonry/Masonry.h>
#import <AVFoundation/AVFoundation.h>

@interface MusicViewController () <MusicViewDelegate>

@property (nonatomic, strong) MusicView *musicView;

@property (nonatomic, strong) NSMutableArray *musicDataArr;

@property (nonatomic, strong) AVAudioPlayer *player;

@property (nonatomic, assign) BOOL isViewAppear;

@end

@implementation MusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _musicView = [MusicView new];
    self.musicView.delegate = self;
    
    [self.view addSubview:self.musicView];
    
    [self.musicView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self initData];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(enterBackground:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)initData{
    _musicDataArr = [NSMutableArray arrayWithCapacity:3];
    {
        MusicModel *model = [MusicModel new];
        model.musicName = @"无";
        [self.musicDataArr addObject:model];
    }
    {
        MusicModel *model = [MusicModel new];
        model.musicName = @"Alan Walker - The Spectre";
        model.musicPath = [[NSBundle mainBundle] pathForResource:model.musicName ofType:@"m4a"];
        model.musicDuration = CMTimeGetSeconds([AVAsset assetWithURL:[NSURL fileURLWithPath:model.musicPath]].duration);
        [self.musicDataArr addObject:model];
    }
    {
        MusicModel *model = [MusicModel new];
        model.musicName = @"Alan Walker - Alone";
        model.musicPath = [[NSBundle mainBundle] pathForResource:model.musicName ofType:@"m4a"];
        model.musicDuration = CMTimeGetSeconds([AVAsset assetWithURL:[NSURL fileURLWithPath:model.musicPath]].duration);
        [self.musicDataArr addObject:model];
    }
    
    [self.musicView setMusicDataArr:self.musicDataArr];
}

#pragma mark - life cycle
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.isViewAppear = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    self.isViewAppear = NO;

    [self.player stop];
}

- (void)enterBackground:(NSNotification *)notifi{
    if (self.isViewAppear) {
        [self.player stop];
    }
}

#pragma mark - MusicViewDelegate
- (void)musicViewOnItemClick:(MusicModel *)model{    
    if (model.musicPath) {
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:model.musicPath] error:nil];
        [self.player play];
    }else {
        [self.player stop];
    }
}

- (void)musicViewOnBack{
    [self.player stop];
    self.player = nil;

    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
