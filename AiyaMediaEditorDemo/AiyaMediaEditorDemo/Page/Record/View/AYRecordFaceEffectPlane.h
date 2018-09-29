//
//  AYRecordFaceEffectPlane.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/24.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceEffectModel.h"

@protocol AYRecordFaceEffectPlaneDelegate <NSObject>

- (void)recordFaceEffectPlaneSelectedModel:(FaceEffectModel *)model;

@end

@interface AYRecordFaceEffectPlane : UIView

@property (nonatomic, weak) id<AYRecordFaceEffectPlaneDelegate> delegate;

@property (nonatomic, strong) NSArray<FaceEffectModel *> *dataArr;

@property (nonatomic, strong) NSString *selectedText;

- (void)hideUseAnim:(BOOL)hidden;

@end
