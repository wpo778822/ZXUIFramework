//
//  ZXPresentAnimatedTransitioningController.h
//  ZXartApp
//
//  Created by Apple on 2017/7/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

typedef void(^ZXContextBlock)(UIView *fromView, UIView *toView);

@interface ZXPresentAnimatedTransitioningController : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, copy) ZXContextBlock willPresentActionHandler;
@property (nonatomic, copy) ZXContextBlock onPresentActionHandler;
@property (nonatomic, copy) ZXContextBlock didPresentActionHandler;
@property (nonatomic, copy) ZXContextBlock willDismissActionHandler;
@property (nonatomic, copy) ZXContextBlock onDismissActionHandler;
@property (nonatomic, copy) ZXContextBlock didDismissActionHandler;

@property (nonatomic, strong) UIView *coverView;

- (ZXPresentAnimatedTransitioningController *)prepareForPresent;
- (ZXPresentAnimatedTransitioningController *)prepareForDismiss;
NS_ASSUME_NONNULL_END

@end
