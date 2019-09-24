//
//  UINavigationController+Alpha.m
//  ZXartApp
//
//  Created by Apple on 2017/9/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "UINavigationController+Alpha.h"
#import <objc/runtime.h>
#import "UIViewController+Alpha.h"

@implementation UINavigationController (Alpha)
// 设置导航栏背景透明度
- (void)setNeedsNavigationBackground:(CGFloat)alpha {
    [self.navigationBar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (@available(iOS 10.0, *)) {
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
             dispatch_async(dispatch_get_main_queue(), ^{
                    obj.alpha = alpha;
                });
            }
        }else if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarBackground")]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                obj.alpha = alpha;
            });
        }
    }];
    self.navigationBar.clipsToBounds = alpha == 0.0;
}

+ (void)initialize {
    if (self == [UINavigationController self]) {
        // 交换方法
        SEL originalSelector = NSSelectorFromString(@"_updateInteractiveTransition:");
        SEL swizzledSelector = NSSelectorFromString(@"et__updateInteractiveTransition:");
        Method originalMethod = class_getInstanceMethod([self class], originalSelector);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

// 交换的方法，监控滑动手势
- (void)et__updateInteractiveTransition:(CGFloat)percentComplete {
    [self et__updateInteractiveTransition:(percentComplete)];
    UIViewController *topVC = self.topViewController;
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor != nil) {
            // 随着滑动的过程设置导航栏透明度渐变
            CGFloat fromAlpha = [[coor viewControllerForKey:UITransitionContextFromViewControllerKey].navBarBgAlpha floatValue];
            CGFloat toAlpha = [[coor viewControllerForKey:UITransitionContextToViewControllerKey].navBarBgAlpha floatValue];
            CGFloat nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete;
            [self setNeedsNavigationBackground:nowAlpha];
        }
    }
}

#pragma mark - UINavigationController Delegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIViewController *topVC = self.topViewController;
    if (topVC != nil) {
        id<UIViewControllerTransitionCoordinator> coor = topVC.transitionCoordinator;
        if (coor != nil) {
            if (@available(iOS 10.0, *)) {
                [coor notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context){
                    [self dealInteractionChanges:context];
                }];
            } else {
                [coor notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context){
                    [self dealInteractionChanges:context];
                }];
            }
        }
    }
}

- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context {
    if ([context isCancelled]) {// 自动取消了返回手势
        NSTimeInterval cancelDuration = [context transitionDuration] * (double)[context percentComplete];
        [UIView animateWithDuration:cancelDuration animations:^{
            CGFloat nowAlpha = [[context viewControllerForKey:UITransitionContextFromViewControllerKey].navBarBgAlpha floatValue];
            [self setNeedsNavigationBackground:nowAlpha];
        }];
    } else {// 自动完成了返回手势
        NSTimeInterval finishDuration = [context transitionDuration] * (double)(1 - [context percentComplete]);
        [UIView animateWithDuration:finishDuration animations:^{
            CGFloat nowAlpha = [[context viewControllerForKey:
                                 UITransitionContextToViewControllerKey].navBarBgAlpha floatValue];
            [self setNeedsNavigationBackground:nowAlpha];
        }];
    }
}


#pragma mark - UINavigationBar Delegate
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item {
    if (self.viewControllers.count >= navigationBar.items.count) {// 点击返回按钮
        UIViewController *popToVC = self.viewControllers[self.viewControllers.count - 1];
        [self setNeedsNavigationBackground:[popToVC.navBarBgAlpha floatValue]];
    }
}

- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item {
    // push到一个新界面
    [self setNeedsNavigationBackground:[self.topViewController.navBarBgAlpha floatValue]];
}
@end
