//
//  ZXSuperCollectionVC.h
//  ZXartApp
//
//  Created by Apple on 2017/11/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+Alpha.h"
#import "ZXMacro.h"
#import "ZXStatusModel.h"
@interface ZXSuperCollectionVC : UICollectionViewController
@property (nonatomic, strong) ZXStatusModel * _Nullable statusModel;
/**
 *  设置nav的左右按钮
 *
 *  @param isRight 右或者左边
 *  @param name    图片名字
 *  @param action  事件
 */
- (void)setBarButton:(BOOL)isRight WithOriginalImage:(NSString *_Nullable)name action:(nullable SEL)action;

/**
 *  返回
 */
- (void)popBack;
@end
