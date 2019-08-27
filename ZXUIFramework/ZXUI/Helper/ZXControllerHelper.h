//
//  ZXControllerRouter.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZXControllerHelper : NSObject
+ (UIViewController *)getControllerWithClassName:(NSString *)className;
+ (UIViewController *)getControllerWithClassName:(NSString *)className
                                       propertys:(NSDictionary *)propertys;

/**
 获取一个VC、设置属性、执行方法

 @param className 类名
 @param propertys 属性字典 -> key-value
 @param method 方法数组字典（目前只支持无返回值无入参方法） dict -> @"methodName" : 方法名
 @return vc
 */
+ (UIViewController *)getControllerWithClassName:(NSString *)className
                                       propertys:(NSDictionary *)propertys
                                          method:(NSArray <NSDictionary *>*)method;
@end

