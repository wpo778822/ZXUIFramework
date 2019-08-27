//
//  ZXAPIManager.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/7.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, ZXAPIManagerGeneral){
    ZXAPIManagerGeneralTest = 0,
    ZXAPIManagerGeneralInner,
    ZXAPIManagerGeneralUAT,
    ZXAPIManagerGeneralPRO,
    ZXAPIManagerGeneralCustom,
};

@interface ZXAPIManager : NSObject
+ (NSString *)general;
+ (NSString *)generalTest;
+ (NSString *)generalInner;
+ (NSString *)generalUAT;
+ (NSString *)generalPRO;
+ (NSString *)generalCustom;
+ (ZXAPIManagerGeneral)generalType;
+ (NSString *)jointURLWithSubArray:(NSArray *)array;
@end
