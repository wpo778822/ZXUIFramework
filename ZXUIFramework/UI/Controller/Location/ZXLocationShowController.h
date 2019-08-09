//
//  ZXLocationShowController.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/6/27.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//
#define LOCATION_AUTHORIZATION_DENIED_TEXT ([NSString stringWithFormat:@"无法获取您的位置信息。\n请到手机系统的[设置]->[隐私]->[定位服务]中打开定位服务,并允许%@使用定位服务。",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]])

#import <UIKit/UIKit.h>
#import "ZXSuperVC.h"
@interface ZXLocationShowController : ZXSuperVC
- (void)showMap:(double)longtitude latidue:(double)latitude address:(NSString *)address;
@end
