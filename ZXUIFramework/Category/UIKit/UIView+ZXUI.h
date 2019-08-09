//
//  UIView+ZXUI.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/8.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (ZXUI)
- (void)addShadowWithColor:(UIColor *)shadowColor
                    radius:(CGFloat)shadowRadius
                    offset:(CGSize)shadowOffset
                   opacity:(CGFloat)shadowOpacity
                    bounds:(BOOL)isBounds;
- (void)cornerRadius:(CGFloat)radius;
@end

@interface UIView (frame)
@property (assign, nonatomic) CGFloat           frameX;

@property (assign, nonatomic) CGFloat           frameY;

@property (assign, nonatomic) CGFloat           frameWidth;

@property (assign, nonatomic) CGFloat           frameHeight;

@property (assign, nonatomic) CGFloat           frameCenterX;

@property (assign, nonatomic) CGFloat           frameCenterY;

@property (assign, nonatomic) CGSize            frameSize;

@end
