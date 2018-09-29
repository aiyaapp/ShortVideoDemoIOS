//
//  AYRadioButton.m
//  AiyaMediaEditorDemo
//
//  Created by 汪洋 on 2018/1/23.
//  Copyright © 2018年 深圳市哎吖科技有限公司. All rights reserved.
//

#import "AYRadioButton.h"
#import "UIButton+ImageWithLable.h"

#import <Masonry/Masonry.h>

@interface AYRadioButton ()

@property (nonatomic, strong) NSArray<NSString *> *texts;
@property (nonatomic, strong) NSMutableArray<UIButton *> *buttons;

@end

@implementation AYRadioButton

- (instancetype)initWithTexts:(NSArray<NSString *> *)texts
{
    self = [super init];
    if (self) {
        _texts = texts;
        
        [self setupView];
    }
    return self;
}

- (void)setupView{
    _buttons = [NSMutableArray arrayWithCapacity:self.texts.count];
    
    for (int x = 0; x < self.texts.count; x++) {
        NSString *text = self.texts[x];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:text forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [button setBackgroundImage:[[UIImage imageNamed:@"xiahua"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 4, 0) resizingMode:UIImageResizingModeStretch] forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
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
    NSInteger index = [self.buttons indexOfObject:bt];
    NSString *text = [self.texts objectAtIndex:index];
    _selectedText = text;
    
    for (UIButton *bt in self.buttons) {
        [bt setSelected:NO];
    }
    
    [bt setSelected:YES];
}

- (void)setSelectedText:(NSString *)selectedText{
    NSInteger index = [self.texts indexOfObject:selectedText];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        [self onButtonClick:button];
    }
}

@end
