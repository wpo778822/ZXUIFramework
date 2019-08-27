//
//  ZXArtLoadingBnView.m
//  ZXartApp
//
//  Created by Apple on 2017/3/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXLoadingView.h"
#import "ZXLoadingSeedView.h"

@implementation ZXLoadingView

+ (instancetype)showLoadingWithFrame:(CGRect)frame seedSize:(CGSize)size bottomImage:(UIImage *)bottomImage topImage:(UIImage *)topImage fillColor:(UIColor *)fillColor{
    ZXLoadingView *loadView = [[ZXLoadingView alloc]initWithFrame:frame];
    loadView.backgroundColor = [UIColor whiteColor];
    ZXLoadingSeedView *realLoading = [[ZXLoadingSeedView alloc] initWithSize:size bottomImage:bottomImage topImage:topImage fillColor:fillColor];
    [loadView addSubview:realLoading];
    realLoading.center = loadView.center;
    return loadView;
}

+ (void)hideTheLoadingViewFromView:(UIView *)superView{
    for (UIView *view in superView.subviews) {
        if ([view isKindOfClass:[ZXLoadingView class]]) {
            ZXLoadingView *bn = (ZXLoadingView*)view;
            [UIView animateWithDuration:0.5 delay:0.f usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                bn.alpha = 0.f;
                [ZXLoadingSeedView hideSeedViewFromView:bn];
            } completion:^(BOOL finished) {
                [bn removeFromSuperview];
            }];
        }
    }
}


+ (void)becomePeakFromView:(UIView *)superView{
    ZXLoadingView *bn;
    for (UIView *view in superView.subviews) {
        if ([view isKindOfClass:[ZXLoadingView class]]) {
            bn = (ZXLoadingView*)view;
        }
    }
    if (bn) {
        [superView bringSubviewToFront:bn];
    }
}

- (void)setOffset:(CGFloat)offset{
    CGRect frame = self.frame;
    frame.origin.y += offset;
    self.frame = frame;
}

@end
