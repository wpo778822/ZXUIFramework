//
//  PropertyInfomation.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/17.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, PropertyType) {
    kNSString,
    kNSNumber,
    kNull,
    kNSDictionary,
    kNSArray,
};

@interface PropertyInfomation : NSObject

/**
 *  属性类型
 */
@property (nonatomic) PropertyType  propertyType;

/**
 *  属性代表值
 */
@property (nonatomic, weak) id    propertyValue;

/**
 *  便利构造器
 *
 *  @param type          属性类型
 *  @param propertyValue 属性代表值
 *
 *  @return 实例对象
 */
+ (instancetype)propertyInfomationWithPropertyType:(PropertyType)type propertyValue:(id)propertyValue;

@end
