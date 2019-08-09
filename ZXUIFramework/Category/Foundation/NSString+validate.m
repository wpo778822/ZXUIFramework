//
//  NSString+validate.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "NSString+validate.h"

@implementation NSString (validate)
- (BOOL)inputMoneyCorrectness {
    NSString *regex = @"^[0-9]{1,8}(\\.[0-9]{0,2})?$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:self]) {
        return NO;
    }
    else {
        return YES;
    }
}

- (BOOL)imageTypeCorrectness {
    NSString *regex = @"^[\\w\\]+.(jpg|png|gif|JPG|PNG|GIF|jpeg|JPEG)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:self]) {
        return NO;
    }
    else {
        return YES;
    }
}

#pragma mark - 验证用户名规则
- (BOOL)userNameCorrectness {
    NSUInteger  character = 0;
    for(int i = 0; i < [self length]; i++) {
        
        int a = [self characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){ //判断是否为中文
            character += 2;
        }else{
            character += 1;
        }
    }
    
    if (character <= 3 || character >= 15) {
        return NO;
    }
    
    NSString *regex = @"[0-9]{2,15}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if ([pred evaluateWithObject:self]) {
        // 用户名都是数字的情况
        return NO;
    }
    //    // 用户名不全是数字
    //    regex = @"^[0-9]+$";
    //    pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    regex = @"[\u4e00-\u9fa5a-zA-Z0-9_]{2,15}$";
    pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (![pred evaluateWithObject:self]) {
        // 错误情况
        return NO;
    }
    else {
        // 正确情况
        return YES;
    }
}

#pragma mark - 验证密码
- (BOOL)passwordCorrectness {
    
    NSString *regex = @"[0-9a-zA-Z_]{6,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:self]) {
        return NO;
    }
    else {
        return YES;
    }
    
}

#pragma mark - 验证手机号
- (BOOL)isPhoneNumber {
    NSString *mobileRegex = @"^(13[0-9]|14[579]|15[0-3,5-9]|16[6]|17[0135678]|18[0-9]|19[89])\\d{8}$";
    NSPredicate *mobileTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", mobileRegex];
    if (![mobileTest evaluateWithObject:self]) {
        return NO;
    }else {
        return YES;
    }
}

#pragma mark - 验证邮箱
- (BOOL)isEmail {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if (![emailTest evaluateWithObject:self]) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL)isRegionCodeISH {
    NSString *RegionCodeRegex = @"\\+?[0-9]{1,4}$";
    NSPredicate *RegionCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", RegionCodeRegex];
    if (![RegionCodeTest evaluateWithObject:self]) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL)isPriceCode {
    NSString *RegionCodeRegex = @"^(([1-9]|0)(\\.\\d{1,2})?";
    NSPredicate *RegionCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", RegionCodeRegex];
    if (![RegionCodeTest evaluateWithObject:self]) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL)isNumberCode {
    NSString *RegionCodeRegex = @"^[0-9]?$";
    NSPredicate *RegionCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", RegionCodeRegex];
    if (![RegionCodeTest evaluateWithObject:self]) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL)isCreditCard {
    NSString *RegionCodeRegex = @"^[0-9]{15,19}$";
    NSPredicate *RegionCodeTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", RegionCodeRegex];
    if (![RegionCodeTest evaluateWithObject:self]) {
        return NO;
    }else {
        return YES;
    }
}

- (NSString *)firstPinyinLetter{
    if (self.length == 0)
        return @"";
    
    //首字符就是字母
    unichar C = [self characterAtIndex:0];
    if((C<= 'Z' && C>='A') || (C <= 'z' && C >= 'a')) {
        //转化为大写拼音
        NSString *pinYin = [[self substringToIndex:1] capitalizedString];
        //获取并返回首字母
        return pinYin;
    }
    
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:[self substringToIndex:1]];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *pinYin = [str capitalizedString];
    //获取并返回首字母
    return [pinYin substringToIndex:1];
}

- (NSString *)retainChinese{
    __block NSString *string = self.copy;
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:NSStringEnumerationByComposedCharacterSequences usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
        NSString *match = @"(^[\u4e00-\u9fa5]+$)";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
        if (![predicate evaluateWithObject:substring]) {
            string = [string stringByReplacingOccurrencesOfString:substring withString:@""];
        }
    }];
    return string;
}

- (NSString *)retainNumber{
    return [self stringByReplacingOccurrencesOfString:@"^\\d+$" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [self length])];
}
- (NSString *)retainCharacter{
    return [self stringByReplacingOccurrencesOfString:@"^[a-zA-Z]+$" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [self length])];
}

@end
