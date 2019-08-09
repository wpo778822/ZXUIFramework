//
//  NSString+validate.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (validate)
/**
 *  验证输入金额是否符合规则(0.01 - 100000.00)
 *
 *  @return 是否符合规则
 */
- (BOOL)inputMoneyCorrectness;

/**
 *  验证图片格式是否符合规则(png/jpeg/gif/jpg)
 *
 *  @return 是否符合规则
 */
- (BOOL)imageTypeCorrectness;

/**
 *  验证用户名规则(只能中英文)
 *
 *  @return 是否符合规则
 */
- (BOOL)userNameCorrectness;

/**
 *  验证密码规则(中英文数字下划线)
 *
 *  @return 是否符合规则
 */
- (BOOL)passwordCorrectness;

/**
 *  验证手机号（国内）
 *
 *  @return 是否符合规则
 */
- (BOOL)isPhoneNumber;

/**
 *  验证邮箱
 *
 *  @return 是否符合规则
 */
- (BOOL)isEmail;

/**
 *  验证地区码
 *
 *  @return 是否符合规则
 */
- (BOOL)isRegionCodeISH;

/**
 是否纯数字
 */
- (BOOL)isNumberCode;

/**
 价格
 */
- (BOOL)isPriceCode;

/**
 *  判断银行卡
 */
- (BOOL)isCreditCard;

//获取拼音首字母(传入汉字字符串, 返回大写拼音首字母)
- (NSString *)firstPinyinLetter;

- (NSString *)retainChinese;
- (NSString *)retainNumber;
- (NSString *)retainCharacter;


@end

NS_ASSUME_NONNULL_END
