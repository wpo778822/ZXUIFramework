//
//  ZXartCityPickViewController.h
//  ZXartApp
//
//  Created by Apple on 2017/11/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXSuperVC.h"
@protocol ZXartCityPickViewControllerDelegate <NSObject>
@optional
/**
 点击事件回调
 */
- (void)cityDidSelected:(NSArray *)array;
@end

@interface ZXartCityPickViewController : ZXSuperVC
/**
 代理
 */
@property (nonatomic, weak) id <ZXartCityPickViewControllerDelegate> delegate;

@property (nonatomic,   copy) NSDictionary *regionsDic;

- (instancetype)initWithSelectedCity:(NSArray *)array
                            delegate:(id<ZXartCityPickViewControllerDelegate>)delegate;
@end
