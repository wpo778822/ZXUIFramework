//
//  NSObject+ZXCategory.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "NSObject+ZXCategory.h"

@implementation NSObject (ZXCategory)
- (void)selectorFromMethodString:(NSString *)methodName{
    SEL selector = NSSelectorFromString(methodName);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(self, selector);
}

- (NSString *)className{
    return NSStringFromClass(self.class);
}
@end
