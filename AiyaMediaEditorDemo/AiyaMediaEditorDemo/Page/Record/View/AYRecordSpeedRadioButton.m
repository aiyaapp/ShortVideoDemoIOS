//
//  AYRecordSpeedRadioButton.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYRecordSpeedRadioButton.h"
#import <Masonry/Masonry.h>

@interface AYRecordSpeedRadioButton ()

@property (nonatomic, strong) NSArray<NSString *> *texts;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;

@end

@implementation AYRecordSpeedRadioButton


- (instancetype)init
{
    self = [super init];
    if (self) {
        _texts = @[@"极慢",@"慢",@"标准",@"快",@"极快"];
        
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.cornerRadius = 3;
    self.clipsToBounds = YES;
    
    _buttons = [NSMutableArray arrayWithCapacity:self.texts.count];
    
    for (int x = 0; x < self.texts.count; x++) {
        NSString *text = self.texts[x];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:text forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor: [UIColor colorWithRed:254/255.0 green:112/255.0 blue:68/255.0 alpha:1/1.0] forState:UIControlStateSelected];
        [button setBackgroundImage:[AYRecordSpeedRadioButton imageFromColor:[UIColor whiteColor]] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:11];
        
        
        [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
        [self.buttons addObject:button];
    }
    
    for (int x = 0; x < self.buttons.count; x++) {
        UIButton *button = self.buttons[x];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            if (x == 0) {
                make.left.equalTo(self.mas_left);
            } else {
                make.left.equalTo(self.buttons[x-1].mas_right);
            }
            make.top.equalTo(self.mas_top);
            make.width.equalTo(self.mas_width).dividedBy(self.texts.count);
            make.bottom.equalTo(self.mas_bottom);
        }];
    }
}

- (void)onButtonClick:(UIButton *)bt{
    for (UIButton *bt in self.buttons) {
        [bt setSelected:NO];
    }
    
    [bt setSelected:YES];
    _selectedText = bt.titleLabel.text;
}

- (void)setSelectedText:(NSString *)selectedText{
    NSInteger index = [self.texts indexOfObject:selectedText];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        [self onButtonClick:button];
    }
}

+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
