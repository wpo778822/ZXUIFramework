//
//  ZXImageScrollView+internal.h
//  ZXartApp
//
//  Created by Apple on 2017/7/6.
//  Copyright © 2017年 Apple. All rights reserved.
//

#ifndef ZXImageScrollView_internal_h
#define ZXImageScrollView_internal_h

#import "ZXImageScrollView.h"

@interface ZXImageScrollView()

/**
 缩放重置

 */
- (void)_handleZoomForLocation:(CGPoint)location;

/**
 滚动置顶
 */
- (void)_scrollToTopAnimated:(BOOL)animated;

/**
 重置视图
 */
- (void)_updateUserInterfaces;
/**
 滑动执行
 */
@property (nonatomic, copy) void(^contentOffSetVerticalPercentHandler)(CGFloat);


/**
  velocity: > 0 up, < 0 down, == 0 others.
 */
@property (nonatomic, copy) void(^didEndDraggingInProperpositionHandler)(CGFloat velocity);

@end


#endif
