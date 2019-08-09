//
//  ZXControllerRouter.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXControllerHelper.h"
#import "NSObject+ZXCategory.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation ZXControllerHelper

+ (UIViewController *)getControllerWithClassName:(NSString *)className{
    return [self getControllerWithClassName:className propertys:nil method:nil];
}

+ (UIViewController *)getControllerWithClassName:(NSString *)className
                                       propertys:(NSDictionary *)propertys{
    return [self getControllerWithClassName:className propertys:propertys method:nil];
}

+ (UIViewController *)getControllerWithClassName:(NSString *)className
                                       propertys:(NSDictionary *)propertys
                                          method:(NSArray<NSDictionary *> *)method{
    Class class = NSClassFromString(className);
   __block UIViewController *vc = [[class alloc] init];
    [propertys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([vc respondsToSelector:NSSelectorFromString(key)]) {
            [vc setValue:obj forKey:key];
        }
    }];
    [method enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj[@"methodName"]) {
            [vc selectorFromMethodString:obj[@"methodName"]];
        }
    }];
    return vc;
}

@end
