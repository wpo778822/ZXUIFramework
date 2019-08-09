//
//  PropertyInfomation.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/17.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "PropertyInfomation.h"

@implementation PropertyInfomation

+ (instancetype)propertyInfomationWithPropertyType:(PropertyType)type propertyValue:(id)propertyValue {
    PropertyInfomation *infomation = [[[self class] alloc] init];
    infomation.propertyType  = type;
    infomation.propertyValue = propertyValue;
    return infomation;
}

@end
