//
//  ZXPopupMenu.h
//  ZXartApp
//
//  Created by Apple on 2016/12/27.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger , ZXPopupMenuType) {
    ZXPopupMenuTypeDefault = 0,
    ZXPopupMenuTypeDark
};

/**
 箭头方向优先级
 
 当控件超出屏幕时会自动调整成反方向
 */
typedef NS_ENUM(NSInteger , ZXPopupMenuPriorityDirection) {
    ZXPopupMenuPriorityDirectionTop = 0,  //Default
    ZXPopupMenuPriorityDirectionBottom,
    ZXPopupMenuPriorityDirectionLeft,
    ZXPopupMenuPriorityDirectionRight,
    ZXPopupMenuPriorityDirectionNone      //不自动调整
};

typedef NS_ENUM(NSInteger, ZXPopupMenuArrowDirection) {
    ZXPopupMenuArrowDirectionTop = 0,  //箭头朝上
    ZXPopupMenuArrowDirectionBottom,   //箭头朝下
    ZXPopupMenuArrowDirectionLeft,     //箭头朝左
    ZXPopupMenuArrowDirectionRight,    //箭头朝右
    ZXPopupMenuArrowDirectionNone      //没有箭头
};

typedef NS_ENUM(NSInteger, ZXPopupMenuAnimation) {
    ZXPopupMenuAnimationTransform = 0,
    ZXPopupMenuAnimationFade,
};


@class ZXPopupMenu;

@protocol ZXPopupMenuDelegate <NSObject>

@optional
/**
 点击事件回调
 */
- (void)zxPopupMenuDidSelectedAtIndex:(NSInteger)index
                          zxPopupMenu:(ZXPopupMenu *)zxPopupMenu;
- (void)zxPopupMenuTouchOutside:(ZXPopupMenu *)zxPopupMenu;
/**
 自定义cell
 
 可以自定义cell，设置后会忽略 fontSize textColor backColor type 属性
 cell 的高度是根据 itemHeight 的，直接设置无效
 建议cell 背景色设置为透明色，不然切的圆角显示不出来
 */
- (UITableViewCell *)zxPopupMenu:(ZXPopupMenu *)zxPopupMenu cellForRowAtIndex:(NSInteger)index;


/**
 视图过程事件通知
 */
- (void)zxPopupMenuBeganShow;
- (void)zxPopupMenuDidShow;
- (void)zxPopupMenuBeganDismiss;
- (void)zxPopupMenuDidDismiss;

@end


@interface ZXPopupMenu : UIView


/**
 圆角半径 Default is 5.0
 */
@property (nonatomic, assign) CGFloat cornerRadius;

/**
 自定义圆角 Default is UIRectCornerAllCorners
 
 当自动调整方向时corner会自动转换至镜像方向
 */
@property (nonatomic, assign) UIRectCorner rectCorner;

/**
 是否显示阴影 Default is YES
 */
@property (nonatomic, assign , getter=isShadowShowing) BOOL isShowShadow;

/**
 是否显示分割线 Default is YES
 */
@property (nonatomic, assign , getter=isSeparatorShowing) BOOL isShowSeparator;

/**
 是否显示灰色覆盖层 Default is YES
 */
@property (nonatomic, assign) BOOL showMaskView;

/**
 选择菜单项后消失 Default is YES
 */
@property (nonatomic, assign) BOOL dismissOnSelected;

/**
 点击菜单外消失  Default is YES
 */
@property (nonatomic, assign) BOOL dismissOnTouchOutside;

/**
 显示搜索栏  Default is NO
 */
@property (nonatomic, assign) BOOL showSearchBar;

/**
 选中效果 Default is UITableViewCellSelectionStyleNone
 */
@property (nonatomic, assign) UITableViewCellSelectionStyle selectionStyle;

/**
 标题文字排列模式 Default is NSTextAlignmentLeft
 */
@property (nonatomic, assign) NSTextAlignment textAlignment;

/**
 设置字体大小 Default is 15
 */
@property (nonatomic, assign) CGFloat fontSize;

/**
 设置字体颜色 Default is [UIColor blackColor]
 */
@property (nonatomic, strong) UIColor * textColor;

/**
 设置偏移距离 (>= 0) Default is 0.0
 */
@property (nonatomic, assign) CGFloat offset;

/**
 边框宽度 Default is 0.0
 
 设置边框需 > 0
 */
@property (nonatomic, assign) CGFloat borderWidth;

/**
 边框颜色 Default is LightGrayColor
 
 borderWidth <= 0 无效
 */
@property (nonatomic, strong) UIColor * borderColor;

/**
 箭头宽度 Default is 15
 */
@property (nonatomic, assign) CGFloat arrowWidth;

/**
 箭头高度 Default is 10
 */
@property (nonatomic, assign) CGFloat arrowHeight;

/**
 箭头位置 Default is center
 
 只有箭头优先级是Left/Right/None时需要设置
 */
@property (nonatomic, assign) CGFloat arrowPosition;

/**
 箭头方向 Default is ZXPopupMenuArrowDirectionTop
 */
@property (nonatomic, assign) ZXPopupMenuArrowDirection arrowDirection;

/**
 箭头优先方向 Default is ZXPopupMenuPriorityDirectionTop （需在ZXPopupMenuArrowDirection 前设置）
 
 当控件超出屏幕时会自动调整箭头位置
 */
@property (nonatomic, assign) ZXPopupMenuPriorityDirection priorityDirection;

/**
 展现动画
 */
@property (nonatomic, assign) ZXPopupMenuAnimation animation;

/**
 可见的最大行数 Default is 5;
 */
@property (nonatomic, assign) NSInteger maxVisibleCount;

/**
 menu背景色 Default is WhiteColor
 */
@property (nonatomic, strong) UIColor * backColor;

/**
 item的高度 Default is 44;
 */
@property (nonatomic, assign) CGFloat itemHeight;

/**
 设置显示模式 Default is ZXPopupMenuTypeDefault
 */
@property (nonatomic, assign) ZXPopupMenuType type;

/**
 实际显示标题数组（搜索时用，暂不支持图标检索）
 */
@property (nonatomic, strong) NSArray *displayTitles;

/**
 代理
 */
@property (nonatomic, weak) id <ZXPopupMenuDelegate> delegate;

/**
 在指定位置弹出(推荐方法)
 
 @param point          弹出的位置
 @param titles         标题数组  数组里是NSString/NSAttributedString
 @param icons          图标数组  数组里是NSString/UIImage
 @param itemWidth      菜单宽度
 @param otherSetting   其他设置
 */
+ (ZXPopupMenu *)showAtPoint:(CGPoint)point
                      titles:(NSArray *)titles
                       icons:(NSArray *)icons
                   menuWidth:(CGFloat)itemWidth
               otherSettings:(void (^) (ZXPopupMenu * popupMenu))otherSetting;

/**
 依赖指定view弹出(推荐方法)
 
 @param titles         标题数组  数组里是NSString/NSAttributedString
 @param icons          图标数组  数组里是NSString/UIImage
 @param itemWidth      菜单宽度
 @param otherSetting   其他设置
 */
+ (ZXPopupMenu *)showRelyOnView:(UIView *)view
                         titles:(NSArray *)titles
                          icons:(NSArray *)icons
                      menuWidth:(CGFloat)itemWidth
                  otherSettings:(void (^) (ZXPopupMenu * popupMenu))otherSetting;

/**
 消失
 */
- (void)dismiss;

@end

