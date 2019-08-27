//
//  ZXArtLoadingBnView.h
//  ZXartApp
//
//  Created by Apple on 2017/3/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXLoadingView : UIView

/**
 实例化一个loading（默认背景-白）

 @param frame 整体大小
 @param size 动画大小
 @param bottomImage 底部主题清晰图片
 @param topImage 顶部轮廓清晰图片
 @param fillColor 填充色
 @return self
 */
+ (instancetype)showLoadingWithFrame:(CGRect)frame seedSize:(CGSize)size bottomImage:(UIImage *)bottomImage topImage:(UIImage *)topImage fillColor:(UIColor *)fillColor;

/**
 隐藏、注销视图、停止动画

 @param superView 父视图
 */
+ (void)hideTheLoadingViewFromView:(UIView *)superView;

/**
 提升视图至父视图最高层
 
 @param superView 父视图
 */
+ (void)becomePeakFromView:(UIView *)superView;

/**
 上下移位 （默认居中）

 @param offset -+上下
 */
- (void)setOffset:(CGFloat)offset;

@end
