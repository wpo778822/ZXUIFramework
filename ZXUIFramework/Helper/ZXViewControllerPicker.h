//
//  ZXViewControllerPicker.h
//  ZXUI
//
//  Created by 黄勤炜 on 2018/7/31.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Cell左滑选择页面跳转方式
 */
@interface ZXViewControllerPicker : UITableViewController

+ (void)activate;

+ (void)activateWithClassPrefix:(NSArray <NSString *> *)prefix;

+ (void)activateWithClassPrefix:(NSArray <NSString *> *)prefix except:(NSArray *)except;

@end
