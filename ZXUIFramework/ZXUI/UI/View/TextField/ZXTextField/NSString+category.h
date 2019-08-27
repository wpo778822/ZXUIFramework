//
//  NSString+category.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (category)
- (BOOL)isChinese;
- (BOOL)isNumber;
- (BOOL)isCharacter;
@end

NS_ASSUME_NONNULL_END
