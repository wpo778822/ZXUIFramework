//
//  ZXartTitleScrollView.h
//  ZXartApp
//
//  Created by Apple on 2017/4/15.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectedBlock)(NSInteger index);

@interface ZXTitleScrollView : UIView

/**
 滑块视图
 */
@property (nonatomic, weak) UIView *selectedView;
/**
 选中的item
 */
@property (nonatomic, weak) UIButton *selectedBtn;
/**
 设置item间隔 Default is 40.0
 */
@property (nonatomic, assign) CGFloat itemEdge;
/**
 滑块的偏离值 Default is 0.0
 */
@property (nonatomic, assign) CGFloat selectedViewOffest;

/**
 设置滑块高度 Default is 3.0
 */
@property (nonatomic, assign) CGFloat selectedLineH;

/**
 是否显示滑块 Default is YES
 */
@property (nonatomic, assign , getter=isSeparatorLineShowing) BOOL isShowSeparatorLine;

/**
 设置滑块颜色 Default is UIColorWithZXArtColor
 */
@property (nonatomic, strong) UIColor *separatorLineColor;

/**
 设置标题常态颜色 Default is UIColorWithTitleColor
 */
@property (nonatomic, strong) UIColor *textColor;

/**
 设置标题选中颜色 Default is UIColorWithZXArtColor
 */
@property (nonatomic, strong) UIColor *selectedTextColor;

/**
 设置字体大小 Default is DEVICE_TYPE_IPHONE_5 ? 16.0:17.0;
 */
@property (nonatomic, assign) CGFloat fontSize;

/**
 是否显示阴影 Default is YES
 */
@property (nonatomic, assign , getter=isShadowShowing) BOOL isShowShadow;

/**
 容器视图
 */
@property (nonatomic, weak) UIScrollView *scrollView;

/**
 标题视图数组
 */
@property (nonatomic, strong) NSMutableArray *buttonArray;

/**
 当前页面的索引
 */
@property (nonatomic, assign) NSInteger currentPage;


/**
 select block
 */
@property (nonatomic, copy) SelectedBlock selected;


/**
 实例化方法
 
 @param titles 标题数组
 */
- (instancetype)initWithTitles:(NSArray *)titles
                      selected:(SelectedBlock)selected;

/**
 定位某一位置
 */
- (void)topBtnClick:(NSInteger)index;

/**
 重置短约束
 */
- (void)remakeConstraints;

@end
