//
//  AYEffectSelectorView.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/2/6.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EffectCellModel.h"

@protocol AYEffectSelectorViewDelegate <NSObject>
@optional

- (void)effectSelectorViewTouchDownModel:(EffectCellModel *)model;

- (void)effectSelectorViewTouchUp;

@end

@interface AYEffectSelectorView : UIView

@property (nonatomic, weak) id<AYEffectSelectorViewDelegate> delegate;

@property (nonatomic, strong) NSArray<EffectCellModel *> *selectorDataArr;

@end
