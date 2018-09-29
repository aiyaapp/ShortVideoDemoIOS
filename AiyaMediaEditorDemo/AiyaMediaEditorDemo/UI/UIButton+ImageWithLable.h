//
//  UIButtonImageWithLable.h
//  aiya
//
//  Created by 汪洋 on 16/8/31.
//  Copyright © 2016年 深圳哎吖科技. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIButton (ImageWithLable)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType padding:(NSInteger)padding;


/**
 设置图片和文字垂直布局
 */
- (void) setVerticalBtWithImage:(UIImage *)image withTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor forState:(UIControlState)stateType padding:(NSInteger)padding;

/**
 设置图片和文字水平布局
 */
- (void) setHorizontalBtWithImage:(UIImage *)image withTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor forState:(UIControlState)stateType padding:(NSInteger)padding;
@end
