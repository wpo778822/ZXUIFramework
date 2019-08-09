//
//  ZXNavigationController.h
//  ZXartApp
//
//  Created by Apple on 2017/1/24.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXNavigationController : UINavigationController
@property (strong   , nonatomic) UINavigationController *navigate;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer;
@end
