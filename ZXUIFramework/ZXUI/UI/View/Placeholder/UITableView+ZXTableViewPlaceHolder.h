//
//  UITableViewController+ZXTableViewPlaceHolder.h
//  ZXartApp
//
//  Created by Apple on 2017/3/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (ZXTableViewPlaceHolder)


/**
 代替 reloadData ，自动添加/移除placeholder功能
 */
- (void)reloadDataAndPlaceHolder;

@end
