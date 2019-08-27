//
//  UIView+Badge.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/30.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXBadgeProtocol.h"

#pragma mark -- badge apis

@interface UIView (ZXBadge)<ZXBadgeProtocol>


/**
 默认圆点
 */
- (void)showBadge;

/**
 显示 "new"
 */
- (void)showNew;

/**
 显示数值
 
 @param value 数值 >= 0
 */
- (void)showNumberBadgeWithValue:(NSInteger)value;


/**
 隐藏视图
 */
- (void)clearBadge;


/**
 显示视图（如果存在）
 */
- (void)resumeBadge;

@end
