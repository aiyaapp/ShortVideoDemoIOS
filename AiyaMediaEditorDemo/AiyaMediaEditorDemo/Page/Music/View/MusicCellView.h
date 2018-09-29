//
//  MusicCellView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/9.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MusicModel.h"

@class MusicCellView;

@protocol MusicCellViewDelegate <NSObject>
@optional

- (void)musicCellViewOnClick:(MusicCellView *)view;

@end

@interface MusicCellView : UIView

@property (nonatomic,weak) id<MusicCellViewDelegate> delegate;

@property (nonatomic, strong) MusicModel *model;

@property (nonatomic, assign) BOOL selected;

@end
