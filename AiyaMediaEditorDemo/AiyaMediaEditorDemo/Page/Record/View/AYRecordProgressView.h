//
//  AYRecordProgressView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MediaItemModel.h"

@interface AYRecordProgressView : UIView

@property (nonatomic, assign) CGFloat longestVideoSeconds;

@property (nonatomic, weak) NSMutableArray *mediaItemArr;

@property (nonatomic, weak) MediaItemModel *recordingMediaItem;

@end
