//
//  ZXHUDHelper.h
//  XYLQ
//
//  Created by mac on 2018/8/17.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZXHUDHelper : NSObject
+ (void)loading;
+ (void)loading:(NSString *)msg;
+ (void)loading:(NSString *)msg inView:(UIView *)view;

+ (void)progress:(float)progress;

+ (void)progress:(float)progress inView:(UIView *)view;

+ (void)tipMessage:(NSString *)msg;
+ (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds;
+ (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)(void))completion;

+ (void)hide;
+ (void)hideInView:(UIView *)view;

@end

