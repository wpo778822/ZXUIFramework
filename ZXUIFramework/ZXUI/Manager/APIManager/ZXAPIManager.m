//
//  ZXAPIManager.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/7.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXAPIManager.h"

@implementation ZXAPIManager

+ (NSString *)general{
    switch ([self generalType]) {
        case ZXAPIManagerGeneralTest:
            return [self generalTest];
            break;
        case ZXAPIManagerGeneralInner:
            return [self generalInner];
            break;
        case ZXAPIManagerGeneralUAT:
            return [self generalUAT];
            break;
        case ZXAPIManagerGeneralPRO:
            return [self generalPRO];
            break;
        case ZXAPIManagerGeneralCustom:
            return [self generalCustom];
            break;
    }
}

+ (NSString *)generalTest{
    return @"";
}

+ (NSString *)generalInner{
    return @"";
}

+ (NSString *)generalUAT{
    return @"";
}

+ (NSString *)generalPRO{
    return @"";
}

+ (NSString *)generalCustom{
    return @"";
}

+ (ZXAPIManagerGeneral)generalType{
    return ZXAPIManagerGeneralTest;
}

+ (NSString *)jointURLWithSubArray:(NSArray *)array{
    return [array componentsJoinedByString:@""];
}

@end
