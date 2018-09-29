//
//  AYRadioButton.h
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AYRadioButton : UIView

@property (nonatomic, strong) NSString *selectedText;

- (instancetype)initWithTexts:(NSArray<NSString *> *)texts;

@end
