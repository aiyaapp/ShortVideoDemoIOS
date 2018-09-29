//
//  AiyaUIButton.m
//  aiya
//
//  Created by 汪洋 on 16/8/31.
//  Copyright © 2016年 深圳哎吖科技. All rights reserved.
//

#import "UIButton+ImageWithLable.h"

@implementation UIButton (ImageWithLable)

- (void) setImage:(UIImage *)image withTitle:(NSString *)title forState:(UIControlState)stateType padding:(NSInteger)padding{
    //UIEdgeInsetsMake(CGFloat top, CGFloat left, CGFloat bottom, CGFloat right)
    
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-titleSize.height-padding,
                                              0.0,
                                              0.0,
                                              -titleSize.width)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(image.size.height + padding,
                                              -image.size.width,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
    [self setTitleColor:[UIColor whiteColor] forState:stateType];
}

- (void) setVerticalBtWithImage:(UIImage *)image withTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor forState:(UIControlState)stateType padding:(NSInteger)padding{
    
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:font}];
    [self.imageView setContentMode:UIViewContentModeCenter];
    [self setImageEdgeInsets:UIEdgeInsetsMake(-titleSize.height-padding,
                                              0.0,
                                              0.0,
                                              -titleSize.width)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:font];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(image.size.height + padding,
                                              -image.size.width,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
    [self setTitleColor:textColor forState:stateType];
}

- (void) setHorizontalBtWithImage:(UIImage *)image withTitle:(NSString *)title font:(UIFont *)font textColor:(UIColor *)textColor forState:(UIControlState)stateType padding:(NSInteger)padding{
    
    [self.imageView setContentMode:UIViewContentModeCenter];
//    [self setImageEdgeInsets:UIEdgeInsetsMake(-titleSize.height-padding,
//                                              0.0,
//                                              0.0,
//                                              -titleSize.width)];
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setFont:font];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0,
                                              padding,
                                              0.0,
                                              0.0)];
    [self setTitle:title forState:stateType];
    [self setTitleColor:textColor forState:stateType];
}

@end


