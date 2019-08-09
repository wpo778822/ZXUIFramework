//
//  NSObject+ZXCategory.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSObject (ZXCategory)
- (void)selectorFromMethodString:(NSString *)methodName;
- (NSString *)className;
@end

