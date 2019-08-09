//
//  ZXFloatLayoutView.h
//  ZXartApp
//
//  Created by Apple on 2018/1/7.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  一种容器视图
 *  支持通过 `contentMode` 属性修改子 View 的对齐方式，目前仅支持 `UIViewContentModeLeft` 和 `UIViewContentModeRight`，默认为 `UIViewContentModeLeft`。
 */
@interface ZXFloatLayoutView : UIView

/**
 *  外部的间距，默认为 UIEdgeInsetsZero
 */
@property(nonatomic, assign) UIEdgeInsets margins;

/**
 *  内部的间距，默认为 UIEdgeInsetsZero
 */
@property(nonatomic, assign) UIEdgeInsets padding;

/**
 *  item 的最小宽高，默认为 CGSizeZero，也即不限制。
 */
@property(nonatomic, assign)  CGSize minimumItemSize;

/**
 *  item 的最大宽高，默认不超过自身。
 */
@property(nonatomic, assign)  CGSize maximumItemSize;

/**
 *  item 之间的间距，默认为 UIEdgeInsetsZero。
 *
 *  @warning 上、下、左、右四个边缘的。
 */
@property(nonatomic, assign) UIEdgeInsets itemMargins;

@end

