//
//  Preview.h
//  AiyaVideoRecord
//
//  Created by 汪洋 on 2017/12/28.
//  Copyright © 2017年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Preview : UIView

/**
 渲染BGRA数据
 */
- (void)render:(CVPixelBufferRef)CVPixelBuffer;

/**
 停止渲染
 */
@property (nonatomic, assign) BOOL renderSuspended;

/**
 当不使用GL时及时释放, 在使用时会自动重新创建
 */
- (void)releaseGLResources;

@end
