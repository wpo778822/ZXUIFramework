//
//  ZXPlaceholder.m
//  ZXartApp
//
//  Created by Apple on 2017/3/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXPlaceholder.h"
#import "ZXMacro.h"
#import <Masonry.h>
@implementation ZXPlaceholder{
    UIImageView * _mainView;
    UILabel * _infoLabel;
    UIButton * _actionBn;
    Action _action;
}

- (instancetype)initWithTitle:(NSString *)title
                        image:(UIImage *)image
                     actionBn:(NSString *)bnName
                       action:(Action)action{
    if (self = [super init]) {
        _placeholderImage     = image;
        _actionButtonName     = bnName;
        _placeholderString    = title;
        _bnBackgroundColor    = ZXBlueColor;
        _offset               = 50.0;
        _bnFontSize           = 14.0;
        _bnTextColor          = [UIColor whiteColor];
        _placeholderFontSize  = 18.0;
        _placeholderTextColor = [UIColor colorUsingRed:223 Green:223 Blue:223];;
        _action               = action;
        self.backgroundColor = [UIColor whiteColor];
        _mainView             = [[UIImageView alloc] initWithImage:_placeholderImage];
        _mainView.contentMode = UIViewContentModeTop;
        [self addSubview: _mainView];
        
        [_mainView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self).offset(self.offset);
        }];
        
        _infoLabel = [[UILabel alloc] init];
        [self addSubview:_infoLabel];
        _infoLabel.font      = UIBOLDFontWithSize(_placeholderFontSize);
        _infoLabel.textColor = _placeholderTextColor;
        _infoLabel.text      = _placeholderString;
        UIImageView *mainView = _mainView;
        [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(mainView.mas_bottom).offset(35);
        }];
        if (_actionButtonName){
            _actionBn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self addSubview:_actionBn];
            _actionBn.backgroundColor = _bnBackgroundColor;
            _actionBn.titleLabel.font = UIFontWithSize(_bnFontSize);
            [_actionBn setTitle:_actionButtonName forState:UIControlStateNormal];
            [_actionBn setTitleColor:_bnTextColor forState:UIControlStateNormal];
            UILabel *infoLabel = _infoLabel;

            [_actionBn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self);
                make.top.equalTo(infoLabel.mas_bottom).offset(20);
                make.size.mas_equalTo(CGSizeMake(78.0, 25.0));
            }];
            [_actionBn addTarget:self action:@selector(action) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return self;
}

+ (instancetype)showCustomWithTitle:(NSString *)title
                              image:(UIImage *)image
                           actionBn:(NSString *)bnName
                          action:(Action)action{
    ZXPlaceholder *placeholder = [[ZXPlaceholder alloc] initWithTitle:title image:image actionBn:bnName action:action];
    return placeholder;
}

+ (instancetype)showFailWithAction:(Action)action{
    ZXPlaceholder *placeholder = [[ZXPlaceholder alloc]initWithTitle:@"您的网络不稳定哦，请刷新重试~" image:[UIImage imageNamed:@"quesheng_wangluozhuangtai" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil] actionBn:@"刷新" action:action];
    return placeholder;
}

+ (instancetype)showNodata{
    ZXPlaceholder *placeholder = [[ZXPlaceholder alloc]initWithTitle:@"暂无数据" image:[UIImage imageNamed:@"quesheng_kongye" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil] actionBn:nil action:nil];
    return placeholder;
}

- (void)action {
    if (_action) {
        _action();
    }
}

- (void)setPlaceholderString:(NSString *)placeholderString{
    _placeholderString = placeholderString;
    _infoLabel.text = placeholderString;
}

- (void)setPlaceholderImage:(UIImage *)placeholderImage{
    _placeholderImage = placeholderImage;
    _mainView.image = _placeholderImage;
}

- (void)setActionButtonName:(NSString *)actionButtonName{
    _actionButtonName = actionButtonName;
    if (actionButtonName)[_actionBn setTitle:actionButtonName forState:UIControlStateNormal];
}

- (void)setOffset:(CGFloat)offset{
    _offset = offset;
    [_mainView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(offset);
    }];
}

- (void)setBnFontSize:(CGFloat)bnFontSize{
    _bnFontSize = bnFontSize;
    _actionBn.titleLabel.font = UIFontWithSize(bnFontSize);
}

- (void)setBnTextColor:(UIColor *)bnTextColor{
    _bnTextColor = bnTextColor;
    [_actionBn setTitleColor:bnTextColor forState:UIControlStateNormal];
}
- (void)setPlaceholderFontSize:(CGFloat)placeholderFontSize{
    _placeholderFontSize = placeholderFontSize;
    _infoLabel.font = UIFontWithSize(placeholderFontSize);
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor{
    _placeholderTextColor = placeholderTextColor;
    _infoLabel.textColor = placeholderTextColor;
}
- (void)setBnBackgroundColor:(UIColor *)bnBackgroundColor{
    _bnBackgroundColor = bnBackgroundColor;
    _actionBn.backgroundColor = bnBackgroundColor;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    _infoLabel.text = _title;
}

- (void)showOrHideActionButton:(BOOL)shouldHide {
    _actionBn.hidden = shouldHide;
}

@end
