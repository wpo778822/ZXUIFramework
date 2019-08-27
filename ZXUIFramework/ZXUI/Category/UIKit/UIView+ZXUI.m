//
//  UIView+ZXUI.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/8.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "UIView+ZXUI.h"

@implementation UIView (ZXUI)
- (void)addShadowWithColor:(UIColor *)shadowColor
                    radius:(CGFloat)shadowRadius
                    offset:(CGSize)shadowOffset
                   opacity:(CGFloat)shadowOpacity
                    bounds:(BOOL)isBounds{
    self.layer.shadowColor   = shadowColor.CGColor;
    self.layer.shadowRadius  = shadowRadius;
    self.layer.shadowOffset  = shadowOffset;
    self.layer.shadowOpacity = shadowOpacity;
    if (isBounds) {
        CGRect shadowFrame       = self.layer.bounds;
        CGPathRef shadowPath     = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
        self.layer.shadowPath    = shadowPath;
    }else{
        self.clipsToBounds = NO;
    }
}

- (void)cornerRadius:(CGFloat)radius{
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius  = radius;
}

@end

@implementation UIView (frame)
- (CGFloat)frameX{
    return self.frame.origin.x;
}

- (void)setFrameX:(CGFloat)x{
    CGRect localFrame = self.frame;
    localFrame.origin.x = x;
    
    self.frame = localFrame;
}

- (CGFloat)frameY{
    return self.frame.origin.y;
}

-(void)setFrameY:(CGFloat)y{
    CGRect localFrame = self.frame;
    localFrame.origin.y = y;
    
    self.frame = localFrame;
}

- (CGFloat)frameWidth{
    return self.frame.size.width;
}

-(void)setFrameWidth:(CGFloat)width{
    CGRect localFrame = self.frame;
    localFrame.size.width = width;
    
    self.frame = localFrame;
}

- (CGFloat)frameHeight{
    return self.frame.size.height;
}

- (void)setFrameHeight:(CGFloat)height{
    CGRect localFrame = self.frame;
    localFrame.size.height = height;
    
    self.frame = localFrame;
}

- (CGFloat)frameCenterX {
    return self.center.x;
}

- (void)setFrameCenterX:(CGFloat)frameCenterX {
    CGPoint localPoint = self.center;
    localPoint.x = frameCenterX;
    self.center = localPoint;
}

- (CGFloat)frameCenterY {
    return self.center.y;
}

- (void)setFrameCenterY:(CGFloat)frameCenterY {
    CGPoint localPoint = self.center;
    localPoint.y = frameCenterY;
    
    self.center = localPoint;
}

- (CGSize)frameSize{
    return self.frame.size;
}

- (void)setFrameSize:(CGSize)frameSize{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            frameSize.width, frameSize.height);
}

@end
