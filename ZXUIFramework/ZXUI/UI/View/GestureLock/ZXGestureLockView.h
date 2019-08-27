//
//  ZXGestureLockView.h
//  ZXUI
//
//  Created by mac on 2018/10/10.
//  Copyright © 2018 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZXGestureLockView;

@protocol ZXGestureLockViewDelegate <NSObject>
@optional

/**
 手势结束

 @param gestureLockView self
 @param pathNumberStr 密码路径
 @return 是否显示错误
 */
- (BOOL)didSelectedGestureLockView:(ZXGestureLockView *)gestureLockView pathNumberStr:(NSString *)pathNumberStr;

@end

/**
 行数默认3，总数默认9。
 */
@interface ZXGestureLockView : UIView
///垂直间隔
@property (nonatomic, assign) CGFloat verticalSpace;
///水平间隔
@property (nonatomic, assign) CGFloat horizontalSpace;
///画线的宽度
@property (nonatomic, assign) CGFloat lineWidth;
///画线的颜色
@property (nonatomic, strong) UIColor *selectedLineColor;
///错误是画线的颜色
@property (nonatomic, strong) UIColor *errorLineColor;
///点的颜色和选择的蒙蔽色
@property (nonatomic, strong) UIColor *normalColor;
///展示错误地状态
@property (nonatomic, assign) BOOL showErrorStatus;

@property (nonatomic, weak) id<ZXGestureLockViewDelegate>delegate;

@end
