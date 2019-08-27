//
//  ZXArtLoadingView.h
//  ZXartApp
//
//  Created by mac  on 2017/1/19.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

// 284.0 232.0

@interface ZXLoadingSeedView : UIView

+ (void)hideSeedViewFromView:(UIView *)superView;
- (instancetype)initWithSize:(CGSize)size bottomImage:(UIImage *)bottomImage topImage:(UIImage *)topImage fillColor:(UIColor *)fillColor;
@end
