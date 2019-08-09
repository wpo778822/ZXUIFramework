//
//  ZXFormView.h
//  XYLQManager
//
//  Created by 黄勤炜 on 2018/8/15.
//  Copyright © 2018年 sino. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXMarqueeLabel.h"

/**
 理论上标题不要超过<5>个字符，理论上取屏幕宽度作为参考
 */
@interface ZXFormView : UIView

/**
 标题颜色
 */
@property (nonatomic, strong) UIColor *titleColor;

/**
 内容标题颜色
 */
@property (nonatomic, strong) UIColor *infoColor;

/**
 标题字体
 */
@property (nonatomic, strong) UIFont *titleFont;

/**
 标题字体
 */
@property (nonatomic, strong) UIFont *infoFont;

/**
 间隔符(显示效果等于标题) - 像素理论上不超过10
 */
@property (nonatomic, copy) NSString *spaceString;

/**
 横向间隔
 */
@property (nonatomic, assign) CGFloat horizontalOffset;

/**
 纵向间隔
 */
@property (nonatomic, assign) CGFloat verticalOffset;

/**
 infoLabel数组(便于赋值)
 */
@property (nonatomic, copy) NSArray<ZXMarqueeLabel *> *infoLabelArray;
- (instancetype)initWithTitleArray:(NSArray *)titleArray;

- (void)inputInfoTextWithArray:(NSArray <NSString *>*)array;

- (instancetype)initWithTitleArray:(NSArray *)titleArray linkBreakIndex:(NSInteger)index;
- (void)setIndexHidden:(BOOL)hidden index:(NSInteger)index;
- (void)requestToStartAnimation;
- (void)requestToStopAnimation;
@end

