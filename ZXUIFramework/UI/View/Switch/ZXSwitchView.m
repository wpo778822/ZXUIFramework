//
//  ZXSwitchView.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXSwitchView.h"
#import <Masonry.h>

@interface ZXSwitchView ()

@property (strong, nonatomic) UISwitch *switchKnob;
@property (strong, nonatomic) UILabel *switchLabel;

@end

#pragma mark

@implementation ZXSwitchView

#pragma mark - Constructors

- (instancetype)init{
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}
#pragma mark - Initialization

- (void)setup{
    self.switchKnob = [[UISwitch alloc]init];
    [self addSubview:self.switchKnob];
    self.switchLabel = [[UILabel alloc] init];
    self.switchLabel.numberOfLines = 1;
    self.switchLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.switchLabel];
    self.labelPosition = ZXSwitchViewLabelPositionLeft;
}

#pragma mark - Getters

- (UIColor *)tintColor{
    return self.switchKnob.tintColor;
}

- (UIColor *)labelColor{
    return self.switchLabel.textColor;
}

- (UIFont *)labelFont{
    return self.switchLabel.font;
}

- (NSString *)labelText{
    return self.switchLabel.text;
}

- (BOOL)isSelected{
    return self.switchKnob.isOn;
}

#pragma mark - Setters

- (void)setTintColor:(UIColor *)tintColor{
    self.switchKnob.onTintColor = tintColor;
}

- (void)setLabelColor:(UIColor *)labelColor{
    self.switchLabel.textColor = labelColor;
}

- (void)setLabelFont:(UIFont *)labelFont{
    self.switchLabel.font = labelFont;
}

- (void)setLabelText:(NSString *)labelText{
    self.switchLabel.text = labelText;
}

- (void)setSelected:(BOOL)selected{
    self.switchKnob.on = selected;
}

- (void)setSwitchScale:(CGFloat)switchScale{
    _switchScale = switchScale;
    self.switchKnob.transform = CGAffineTransformMakeScale(switchScale,switchScale);
}

- (void)setLabelPosition:(ZXSwitchViewLabelPosition)labelPosition{
    _labelPosition = labelPosition;
    [self.switchLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        if (labelPosition == ZXSwitchViewLabelPositionLeft) {
            make.top.leading.bottom.equalTo(self);
        }else if (labelPosition == ZXSwitchViewLabelPositionRight){
            make.top.right.bottom.equalTo(self);
        }
    }];
    [self.switchKnob mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.switchLabel);
        if (labelPosition == ZXSwitchViewLabelPositionLeft) {
            make.leading.equalTo(self.switchLabel.mas_trailing);
            make.trailing.equalTo(self);
        }else if (labelPosition == ZXSwitchViewLabelPositionRight){
            make.trailing.equalTo(self.switchLabel.mas_leading);
            make.leading.equalTo(self);
        }
    }];
}

@end
