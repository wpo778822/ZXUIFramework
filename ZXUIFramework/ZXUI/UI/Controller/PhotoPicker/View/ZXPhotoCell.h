//
//  ZXPhotoCell.h
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import <Photos/Photos.h>
#import <UIKit/UIKit.h>

/**
 图片显示cell
 */
@interface ZXPhotoCell : UICollectionViewCell

/**
 图标标识符（异步加载比对）
 */
@property (nonatomic, strong) NSString *representedAssetIdentifier;

/**
 长按手势
 */
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;

/**
 选择顺序
 */
@property (nonatomic, assign) NSUInteger selectionOrder;

/**
 图片显示方法

 @param manager 图片管理对象
 @param asset 图标资源对象
 @param size 图片目标大小
 */
- (void)loadPhotoWithManager:(PHImageManager *)manager forAsset:(PHAsset *)asset targetSize:(CGSize)size;


/**
 选中动画
 */
- (void)setNeedsAnimateSelection;

/**
 高亮（触摸停留效果）

 @param highlighted 是否高亮显示
 */
- (void)animateHighlight:(BOOL)highlighted;

@end
