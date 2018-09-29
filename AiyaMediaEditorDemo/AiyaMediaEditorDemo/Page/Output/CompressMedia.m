//
//  CompressMedia.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/28.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "CompressMedia.h"
#import "MP4ReEncode.h"

typedef void(^Handler)(BOOL);

@interface CompressMedia () <MP4ReEncodeDelegate>

@property (nonatomic, strong) MP4ReEncode *reencode;

@property (nonatomic, copy) Handler handler;

@end

@implementation CompressMedia

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reencode = [[MP4ReEncode alloc] init];
        self.reencode.delegate = self;
        
        [self.reencode initSetup];
    }
    return self;
}

- (void)setInputURL:(NSURL *)inputURL{
    _inputURL = inputURL;
    
    [self.reencode setInputURL:inputURL];
}

- (void)setOutputURL:(NSURL *)outputURL{
    _outputURL = outputURL;
    
    [self.reencode setOutputURL:outputURL];
}

- (void)setVideoBitrate:(unsigned int)bitrate{
    [self.reencode SetBitrate:bitrate];
}

- (void)setAudioBitrate:(unsigned int)bitrate{
    [self.reencode setAudioBitrate:bitrate];
}

- (void)exportAsynchronouslyWithCompletionHandler:(void (^)(BOOL))handler{
    [self.reencode startReencode];
    
    _handler = handler;
}

#pragma mark - MP4ReEncodeDelegate
- (void)MP4ReEncodeFinish:(bool)success{
    if (self.handler) {
        self.handler(success);
    }
}

@end
