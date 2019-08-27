//
//  ADScrollView.h
//  unlimitedADScrollViews
//
//  Created by mac  on 2016/11/22.
//  Copyright © 2016年 mac . All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage.h>
@class ADScrollView;
@protocol ADsViewDelegate <NSObject>

@optional
/**
 广告重新加载
 
 */
- (void)reloadADdata:(ADScrollView *)adScrollView;

/**
 广告点击代理

 @param page 选中的页数
 */
- (void)didSelectedWhichAD:(NSInteger)page adScrollView:(ADScrollView *)adScrollView;

/**
 广告滚动页面触发方法

 @param page 当前的页数
 */
- (void)didEndDeceleratingWhichAD:(NSInteger)page adScrollView:(ADScrollView *)adScrollView;

@end

@interface ADScrollView : UIView

/**
 是否自动滚动 Default is YES
 */
@property (nonatomic, assign , getter=isScrollAutomatic) BOOL isAutomaticScroll;

/**
 是否单张循环滚动 Default is NO
 */
@property (nonatomic, assign , getter=isSheelLoop) BOOL isLoopShell;

/**
 是否自动循环滚动 Default is YES
 */
@property (nonatomic, assign , getter=isScrollLoop) BOOL isLoopScroll;

/**
 是否显示指示器 Default is YES (数量唯一时隐藏)
 */
@property (nonatomic, assign , getter=isPageControlShowing) BOOL isShowPageControl;

/**
 广告图片数组
 */
@property (nonatomic, copy) NSArray *ADArray;

/**
 默认占位图
 */
@property (nonatomic, strong) UIImage *placeHolderImage;

/**
 代理
 */
@property (nonatomic,weak) id<ADsViewDelegate> delegate;

/**
 当前广告图片视图
 */
@property (nonatomic, strong) YYAnimatedImageView *centerImageView;

/**
 广告轮播背景视图
 */
@property (nonatomic, strong) UIScrollView *scrollView;

/**
 广告轮播位置 Default is 0
 */
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, assign) BOOL isNormalPageControl;

@end
