//
//  ZXNavigationController.m
//  ZXartApp
//
//  Created by Apple on 2017/1/24.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXNavigationController.h"



@interface ZXNavigationController ()<UIGestureRecognizerDelegate,UINavigationControllerDelegate>
@end

@implementation ZXNavigationController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.delegate                           = self;
    self.navigationBar.barTintColor         = [UIColor whiteColor];//背景颜色
    NSMutableDictionary *attrnor            = [NSMutableDictionary dictionary];
    attrnor[NSFontAttributeName]            = [UIFont systemFontOfSize:18];//标题大小
    attrnor[NSForegroundColorAttributeName] = [UIColor whiteColor];//标题颜色
    self.navigationBar.titleTextAttributes  = attrnor.copy;
    
    __weak ZXNavigationController *weakSelf = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]){
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = (id)weakSelf;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES ) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [super pushViewController:viewController animated:animated];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated{
    if ( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] && animated == YES ) {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return  [super popToRootViewControllerAnimated:animated];
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if( [self respondsToSelector:@selector(interactivePopGestureRecognizer)] ){
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    return [super popToViewController:viewController animated:animated];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate {
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.enabled = YES;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.interactivePopGestureRecognizer ){
        if ( self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    return YES;
}

- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer{
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if (self.view.gestureRecognizers.count > 0){
        for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers){
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]){
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }
    return screenEdgePanGestureRecognizer;
}

@end
