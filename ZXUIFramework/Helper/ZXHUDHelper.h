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
//+ (void)alert:(NSString *)msg;
//+ (void)alert:(NSString *)msg action:(void (^)(void))action;
//+ (void)alert:(NSString *)msg cancel:(NSString *)cancel;
//+ (void)alert:(NSString *)msg cancel:(NSString *)cancel action:(void (^)(void))action;
//+ (void)alertTitle:(NSString *)title message:(NSString *)msg cancel:(NSString *)cancel;
//+ (void)alertTitle:(NSString *)title message:(NSString *)msg cancel:(NSString *)cancel action:(void (^)(void))action;

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

