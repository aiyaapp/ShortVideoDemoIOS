//
//  PlayerPreview.m
//  EffectCamera
//
//  Created by 汪洋 on 2018/1/4.
//  Copyright © 2018年 深圳哎吖科技. All rights reserved.
//

#import "PlayerPreview.h"
#import <AVFoundation/AVFoundation.h>

@implementation PlayerPreview

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
