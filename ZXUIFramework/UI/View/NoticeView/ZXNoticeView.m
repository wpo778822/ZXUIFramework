//
//  ZXNoticeView.m
//  ZXartApp
//
//  Created by Apple on 2017/6/21.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXNoticeView.h"
#import "ZXMacro.h"
#import "UIView+ZXUI.h"
#import <Masonry.h>
@implementation ZXNoticeView{
    UILabel *_label;
    UIImageView *_imageView;
    CGFloat _dunrationTime;
    CGFloat _residenceTime;
    CGFloat _height;
    Completion _completion;
}

- (instancetype)initWithInfoString:(NSString *)string
                              type:(ZXNoticeType)type
                     dunrationTime:(CGFloat)dunrationTime
                     residenceTime:(CGFloat)residenceTime
                          delegate:(id<ZXNoticeViewDelegate>)delegate
                        completion:(Completion)completion{
    self = [super init];
    if (self) {
        _height = NAVBAR_HEIGHT + 7;
        self.windowLevel     = UIWindowLevelAlert;
        self.frame           = CGRectMake(0, -_height, SCREEN_WIDTH, _height);
        self.backgroundColor = [UIColor whiteColor];
        self.hidden          = NO;
        _dunrationTime       = dunrationTime;
        _completion          = completion;
        _residenceTime       = residenceTime;
        if (delegate) {
            _delegate = delegate;
            self.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapAction)];
            [self addGestureRecognizer:singleTap];
        }
        _imageView = [[UIImageView alloc]init];
        [self addSubview:_imageView];
        _label = [[UILabel alloc]init];
        [self addSubview:_label];
        _label.font = UIFontWithSize(15.0);
        _label.numberOfLines = 2;
        [_label setTextColor:ZXSubTitleColor];
        _label.adjustsFontSizeToFitWidth = YES;
        [self cornerRadius:5];
        [self addShadowWithColor:[UIColor colorUsingHexString:@"#999999"] radius:2.0 offset:CGSizeMake(0, 1) opacity:0.5 bounds:NO];
        switch (type) {
            case ZXNoticeTypeError:
                [_imageView setImage:[UIImage imageNamed:@"notice_bar_error" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil]];
                break;
            case ZXNoticeTypeSuccess:
                [_imageView setImage:[UIImage imageNamed:@"notice_bar_success" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil]];
                break;
            case ZXNoticeTypeInfo:
                [_imageView setImage:[UIImage imageNamed:@"notice_bar_info" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil]];
                break;
            case ZXNoticeTypeFail:
                [_imageView setImage:[UIImage imageNamed:@"notice_bar_fail" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil]];
                break;
            case ZXNoticeTypeMessage:
                _label.font = UIFontWithSize(16.0);
                [_label setTextColor:[UIColor whiteColor]];
                self.backgroundColor = [UIColor colorUsingHexString:@"#0084ff"];
                break;
            default:
                break;
        }
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset(8.0);
            make.centerY.equalTo(self).offset(10.0);
        }];
        CGFloat width = _imageView.image.size.width;
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.equalTo(self).offset( width + 13.0);
            make.trailing.equalTo(self).offset(-13.0);
            make.centerY.equalTo(self).offset(10.0);
        }];

        [self setInfoString:string completion:completion];
        if (self.delegate && [self.delegate respondsToSelector:@selector(zxNoticeViewWillAppear:)]) {
            [self.delegate zxNoticeViewWillAppear:self];
        }
        if (residenceTime == 0.f) {
            UIPanGestureRecognizer *pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(methodPanGesture:)];
            [self addGestureRecognizer:pangesture];
        }else{
            GCDTime((_dunrationTime + residenceTime), ^{
                [self setInfoString:nil completion:completion];
            });
        }
    }
    return self;
}

- (void)singleTapAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(zxNoticeViewAction:)]) {
        [self.layer removeAllAnimations];
        self.userInteractionEnabled = NO;
        [self.delegate zxNoticeViewAction:self];
        [self setInfoString:nil completion:_completion];
    }
}

- (void)methodPanGesture:(UIPanGestureRecognizer *)pan{
    if (UIGestureRecognizerStateEnded == pan.state) {
        [self setInfoString:nil completion:_completion];
 }
}

- (void)setInfoString:(NSString *)infoString
         completion:(Completion)completion{
    [UIView animateWithDuration:_dunrationTime delay:0.f
         usingSpringWithDamping:_dunrationTime / 2
          initialSpringVelocity:_dunrationTime
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         CGRect frame = self.frame;
        if (self.frame.origin.y == -self->_height) {
            frame.origin = CGPointMake(0, -6);
            [self->_label setText:infoString];
        }else{
            frame.origin = CGPointMake(0, -self->_height - 1.f);
        }
                         self.frame = frame;
    } completion:^(BOOL finished) {
        if (!infoString) {
            [self removeFromSuperview];
            if (completion) {
                completion();
            }
        }
    }];
}


+ (instancetype)showNoticeViewWithInfoString:(NSString *)string
                                        type:(ZXNoticeType)type
                                  completion:(Completion)completion{
    ZXNoticeView *noticeView = [[ZXNoticeView alloc]initWithInfoString:string
                                                                  type:type
                                                         dunrationTime:1.2
                                                         residenceTime:0.6
                                                              delegate:nil
                                                            completion:completion];
    return noticeView;
}

+ (instancetype)showNoticeViewWithInfoString:(NSString *)string
                                        type:(ZXNoticeType)type
                               dunrationTime:(CGFloat)dunrationTime
                               residenceTime:(CGFloat)residenceTime
                                    delegate:(id<ZXNoticeViewDelegate>)delegate
                                  completion:(Completion)completion {
    ZXNoticeView *noticeView = [[ZXNoticeView alloc]initWithInfoString:string
                                                                  type:type
                                                         dunrationTime:dunrationTime
                                                         residenceTime:residenceTime
                                                              delegate:delegate
                                                            completion:completion];
    return noticeView;
}

@end
