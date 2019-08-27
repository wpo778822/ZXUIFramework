//
//  ZXSlideMenu.h
//  EasyHome
//
//  Created by 黄勤炜 on 2018/7/19.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXSlideMenu : UIViewController
@property (nonatomic, strong) UIViewController *rootViewController;
@property (nonatomic, strong) UIViewController *leftViewController;
@property (nonatomic, strong) UIViewController *rightViewController;
@property (nonatomic, assign) CGFloat menuWidth;
//留白宽度
@property (nonatomic, assign, readonly) CGFloat emptyWidth;
//滑动手势
@property (nonatomic ,assign) BOOL slideEnabled;
//创建方法
- (instancetype)initWithRootViewController:(UIViewController*)rootViewController;

//显示主视图
- (void)showRootViewControllerAnimated:(BOOL)animated;
//显示左侧菜单
- (void)showLeftViewControllerAnimated:(BOOL)animated;
//显示右侧菜单
- (void)showRightViewControllerAnimated:(BOOL)animated;

@end

@interface UIViewController (SlideMenu)

@property (nonatomic, strong, readonly) ZXSlideMenu *sldeMenu;

@end

