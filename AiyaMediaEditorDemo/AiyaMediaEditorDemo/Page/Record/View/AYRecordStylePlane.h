//
//  AYRecordStylePlane.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/24.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StyleModel.h"

@protocol AYRecordStylePlaneDelegate <NSObject>
@optional

- (void)recordStylePlaneSelectedModel:(StyleModel *)model;

@end

@interface AYRecordStylePlane : UIView

@property (nonatomic, weak) id<AYRecordStylePlaneDelegate> delegate;

@property (nonatomic, strong) NSArray<StyleModel *> *dataArr;

@property (nonatomic, strong) NSString *selectedText;

- (void)hideUseAnim:(BOOL)hidden;

@end
