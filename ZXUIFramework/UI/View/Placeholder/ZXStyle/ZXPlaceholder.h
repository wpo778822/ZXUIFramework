//
//  ZXPlaceholder.h
//  ZXartApp
//
//  Created by Apple on 2017/3/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZXPlaceholder;
typedef void (^Action)(void);


@interface ZXPlaceholder : UIView
/**
 垂直偏移量 Default is 50
 */
@property (nonatomic, assign) CGFloat offset;

/**
 设置提示字体大小 Default is 14
 */
@property (nonatomic, assign) CGFloat placeholderFontSize;

/**
 设置提示字体颜色 Default is #666666
 */
@property (nonatomic, strong) UIColor *placeholderTextColor;

/**
 设置按钮字体大小 Default is 14
 */
@property (nonatomic, assign) CGFloat bnFontSize;

/**
 设置按钮字体颜色 Default is [UIColor whileColor]
 */
@property (nonatomic, strong) UIColor *bnTextColor;

/**
 设置按钮背景颜色 Default is ZXartColor
 */
@property (nonatomic, strong) UIColor *bnBackgroundColor;

/**
 占位提示信息
 */
@property (nonatomic, copy) NSString *placeholderString;
/**
 占位图片名
 */
@property (nonatomic, copy) NSString *imageName;

/**
 回调按钮名
 */
@property (nonatomic, copy) NSString *actionButtonName;

@property (nonatomic,   copy) NSString *title;

/**
 指定标题和图片
 @param title 提示标题
 @param iconName 占位图片
 @param bnName 回调按钮名
 */
+ (instancetype)showCustomWithTitle:(NSString *)title
                               icon:(NSString *)iconName
                           actionBn:(NSString *)bnName
                             action:(Action)action;

/**
 下载超时占位图
 */
+ (instancetype)showFailWithAction:(Action)action;

/**
 默认无数据占位图
 */
+ (instancetype)showNodata;

- (void)showOrHideActionButton:(BOOL)shouldHide;

@end
