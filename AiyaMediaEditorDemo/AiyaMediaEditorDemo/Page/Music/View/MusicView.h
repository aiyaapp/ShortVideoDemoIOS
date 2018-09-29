//
//  MusicView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/9.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicModel.h"

@class MusicModel;
@protocol MusicViewDelegate <NSObject>

- (void)musicViewOnBack;

- (void)musicViewOnItemClick:(MusicModel *)model;

@end

@interface MusicView : UIView

@property (nonatomic, weak) id<MusicViewDelegate> delegate;

@property (nonatomic, strong) NSArray<MusicModel *> *musicDataArr;

@end
