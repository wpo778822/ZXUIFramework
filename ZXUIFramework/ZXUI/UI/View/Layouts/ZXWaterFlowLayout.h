//
//  ZXWaterFlowLayout.h
//  ZXartApp
//
//  Created by Apple on 2017/1/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger , ZXWaterFlowLayoutType) {
    ZXWaterFlowLayoutHorizontalScrollIndicator = 0,//竖向
    ZXWaterFlowLayoutVerticalScrollIndicator
};
@protocol ZXWaterFlowLayoutDelegate <NSObject>

@required
/**
 单个cell高/宽度返回
 
 @param layout 当前layout对象
 @param itemWidth 垂直布局 ？宽度:高度
 @param indexPath 当前布局位置
 @param collectionView 当前collectionView对象
 @return 垂直布局 ？高度:宽度
 */
- (CGFloat)waterFlowLayout:(UICollectionViewLayout *)layout
                 itemWidth:(CGFloat)itemWidth
                 indexPath:(NSIndexPath *)indexPath
            collectionView:(UICollectionView *)collectionView;
@end

@interface ZXWaterFlowLayout : UICollectionViewLayout

/**
 列数 Default is 2
 */
@property (nonatomic, assign) NSInteger columnCount;

/**
 列间距 Default is 10
 */
@property (nonatomic, assign) CGFloat columnMargin;

/**
 行间距 Default is 10
 */
@property (nonatomic, assign) CGFloat rowMargin;

/**
 边缘间距 Default is {10, 10, 10, 10}
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/**
 导航栏+状态栏高度偏移值 Default is 64.0
 */
@property (nonatomic, assign) CGFloat offset;


/**
 设置布局 Default is ZXWaterFlowLayoutHorizontalScrollIndicator
 */
@property (nonatomic, assign) ZXWaterFlowLayoutType type;

/**
 代理
 */

@property (nonatomic,weak) id<ZXWaterFlowLayoutDelegate> delegate;

@end
