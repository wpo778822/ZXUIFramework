//
//  ZXMarqueeLabel.h
//  Demo
//
//  Created by 黄勤炜 on 2018/8/7.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 足够长滚动时文字默认显示居左（已占全满），反之显示支持的left、center、right三种
 行数显示为1
 */
@interface ZXMarqueeLabel : UILabel

/**
 控制滚动的速度，根据刷新率位移， 默认为 .5.
 */
@property(nonatomic, assign) CGFloat speed;

/**
 停顿时长，默认为 2.5秒（包括起始静止时间）。
 */
@property(nonatomic, assign) NSTimeInterval pauseDurationWhenMoveToEdge;

/**
 用于控制首尾连接的文字之间的间距，默认为 20。
 */
@property(nonatomic, assign) CGFloat spacingBetweenHeadToTail;

/**
 *  自动判断 label 的 frame 是否超出当前的 UIWindow 可视范围，超出则自动停止动画。默认为 YES。
 *  @warning 某些场景并无法触发这个自动检测（例如直接调整 label.superview 的 frame 而不是 label 自身的 frame），这种情况暂不处理。
 */
@property(nonatomic, assign) BOOL automaticallyValidateVisibleFrame;

/**
 在文字滚动到左右边缘时，是否显示阴影渐变遮罩，默认为 NO。
 */
@property(nonatomic, assign) BOOL shouldFadeAtEdge;

/**
 渐变遮罩的宽度，默认为 20。
 */
@property(nonatomic, assign) CGFloat fadeWidth;

/**
 渐变遮罩外边缘的颜色
 */
@property(nonatomic, strong) UIColor *fadeStartColor;

/**
 渐变遮罩内边缘的颜色
 */
@property(nonatomic, strong) UIColor *fadeEndColor;

/**
 循环完成后是否从边缘开始，默认为NO,忽略 shouldFadeAtEdge 值。
 */
@property(nonatomic, assign) BOOL textStartAfterFade;
@end


/// 在可复用的 UIView 里使用（例如 UITableViewCell、UICollectionViewCell），由于 UIView 重复被使用，需要l合理的手动开启/关闭 label 的动画。
@interface ZXMarqueeLabel (ReusableView)

/**
 *  尝试开启 label 的滚动动画
 *  @return 是否成功开启
 */
- (BOOL)requestToStartAnimation;

/**
 *  尝试停止 label 的滚动动画
 *  @return 是否成功停止
 */
- (BOOL)requestToStopAnimation;
@end
