//
//  ZXButton.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXAlertButton.h"
#import "ZXTimerDisplay.h"

#define MARGIN_BUTTON 12.0f
#define MIN_HEIGHT 35.0f

@implementation ZXAlertButton

- (instancetype)initWithWindowWidth:(CGFloat)windowWidth{
    self = [super init];
    if (self){
        [self setupWithWindowWidth:windowWidth];
    }
    return self;
}

- (void)setupWithWindowWidth:(CGFloat)windowWidth{
    self.frame = CGRectMake(0.0f, 0.0f, windowWidth - (MARGIN_BUTTON * 2), MIN_HEIGHT);
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.layer.cornerRadius = 3.0f;
}

- (void)adjustWidthWithWindowWidth:(CGFloat)windowWidth numberOfButtons:(NSUInteger)numberOfButtons{
    CGFloat allButtonsWidth = windowWidth - (MARGIN_BUTTON * 2);
    CGFloat buttonWidth = (allButtonsWidth - ((numberOfButtons - 1) * 10)) / numberOfButtons;
    
    self.frame = CGRectMake(0.0f, 0.0f, buttonWidth, MIN_HEIGHT);
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state{
    [super setTitle:title forState:state];
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel sizeToFit];
    [self layoutIfNeeded];
    CGFloat buttonHeight = MAX(self.titleLabel.frame.size.height, MIN_HEIGHT);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, buttonHeight);
}

- (void)setHighlighted:(BOOL)highlighted{
    self.backgroundColor = (highlighted) ? [self darkerColorForColor:_defaultBackgroundColor] : _defaultBackgroundColor;
    [super setHighlighted:highlighted];
}

- (void)setDefaultBackgroundColor:(UIColor *)defaultBackgroundColor{
    self.backgroundColor = _defaultBackgroundColor = defaultBackgroundColor;
}

- (void)setTimer:(ZXTimerDisplay *)timer{
    _timer = timer;
    [self addSubview:timer];
    [timer updateFrame:self.frame.size];
    timer.color = self.titleLabel.textColor;
}

#pragma mark - Button Apperance

- (void)parseConfig:(NSDictionary *)buttonConfig{
    if (buttonConfig[@"backgroundColor"]){
        self.defaultBackgroundColor = buttonConfig[@"backgroundColor"];
    }
    if (buttonConfig[@"textColor"]){
        [self setTitleColor:buttonConfig[@"textColor"] forState:UIControlStateNormal];
    }
    if (buttonConfig[@"cornerRadius"]){
        self.layer.cornerRadius = [buttonConfig[@"cornerRadius"] floatValue];
    }
    if ((buttonConfig[@"borderColor"]) && (buttonConfig[@"borderWidth"])){
        self.layer.borderColor = ((UIColor*)buttonConfig[@"borderColor"]).CGColor;
        self.layer.borderWidth = [buttonConfig[@"borderWidth"] floatValue];
    }
    else if (buttonConfig[@"borderWidth"]){
        self.layer.borderWidth = [buttonConfig[@"borderWidth"] floatValue];
    }
    if (buttonConfig[@"font"]) {
        self.titleLabel.font = buttonConfig[@"font"];
    }
}

#pragma mark - Helpers

- (UIColor *)darkerColorForColor:(UIColor *)color{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MAX(r - 0.2f, 0.0f)
                               green:MAX(g - 0.2f, 0.0f)
                                blue:MAX(b - 0.2f, 0.0f)
                               alpha:a];
    return nil;
}

- (UIColor *)lighterColorForColor:(UIColor *)color{
    CGFloat r, g, b, a;
    if ([color getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2f, 1.0f)
                               green:MIN(g + 0.2f, 1.0f)
                                blue:MIN(b + 0.2f, 1.0f)
                               alpha:a];
    return nil;
}

@end
