//
//  ZXSuperVC.h
//  ZXartApp
//
//  Created by blingman on 2017/7/27.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Alpha.h"
#import "ZXMacro.h"
#import "ZXStatusModel.h"

@interface ZXSuperVC : UIViewController
@property (nonatomic, strong) ZXStatusModel * _Nullable statusModel;

/**
 *  设置nav的左右按钮
 *
 *  @param isRight 右或者左边
 *  @param originalImage    图片
 *  @param action  事件
 */
- (void)setBarButton:(BOOL)isRight originalImage:(UIImage *_Nullable)originalImage action:(nullable SEL)action;
/**
 *  默认返回按钮的事件
 */
- (void)popBack;

@property (nonatomic, assign) BOOL isOriginal;
@end
