//
//  VideoEffectModel.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/3/1.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoEffectModel : NSObject

@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString *text;

@property (nonatomic, assign) NSUInteger effectType;

@end
