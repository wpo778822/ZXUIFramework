//
//  ZXWaterFlowLayout.m
//  ZXartApp
//
//  Created by Apple on 2017/1/23.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXWaterFlowLayout.h"

@interface ZXWaterFlowLayout ()
/**
 存储布局属性
 */
@property (nonatomic, strong) NSMutableArray *attrsArray;
/**
 存储所有列的实时高度
 */
@property (nonatomic, strong) NSMutableArray *columnHeights;
@property (nonatomic, assign) BOOL isHorizon;
@end

@implementation ZXWaterFlowLayout{
    NSInteger kColumnCount;
    CGFloat kColumnMargin;
    CGFloat kRowMargin;
    CGFloat kOffset;
    UIEdgeInsets kEdgeInsets;
}
@synthesize columnCount = kColumnCount,columnMargin = kColumnMargin,rowMargin = kRowMargin,offset = kOffset,edgeInsets = kEdgeInsets;
- (instancetype)init{
    self = [super init];
    if (self) {
        _type         = ZXWaterFlowLayoutHorizontalScrollIndicator;
        kColumnCount  = 2;
        kColumnMargin = 10;
        kRowMargin    = 10;
        kOffset       = 64.0;
        kEdgeInsets   = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
    }
    return self;
}
- (void)setRowMargin:(CGFloat)rowMargin{
    kRowMargin = rowMargin;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets{
    kEdgeInsets = edgeInsets;
}

- (void)setColumnCount:(NSInteger)columnCount{
    kColumnCount = columnCount;
}

- (void)setColumnMargin:(CGFloat)columnMargin{
    kColumnMargin = columnMargin;
}

- (void)setOffset:(CGFloat)offset{
    kOffset = offset;
}

- (NSMutableArray *)columnHeights{
    if (!_columnHeights) {
        _columnHeights = [NSMutableArray array];
    }
    return _columnHeights;
}

- (NSMutableArray *)attrsArray{
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

- (BOOL)isHorizon{
    _isHorizon = _type == ZXWaterFlowLayoutHorizontalScrollIndicator ? YES : NO;
    return _isHorizon;
}

/**
 * 初始化
 */
- (void)prepareLayout{
    [super prepareLayout];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    if (count == 0 || kColumnCount < 1) return;
    
    // 清除以前计算的所有高度
    [self.columnHeights removeAllObjects];
    
    // 加入预设高度
    for (NSInteger i = 0; i < kColumnCount; i++) {
        [self.columnHeights addObject:@(kEdgeInsets.top)];
    }
    
    // 清除之前所有的布局属性
    [self.attrsArray removeAllObjects];
    
    // 开始创建每一个cell对应的布局属性
    for (NSInteger i = 0; i < count; i++) {
        // 创建位置
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        // 获取indexPath位置cell对应的布局属性
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        [self.attrsArray addObject:attrs];
    }
    
}

/**
 * 决定cell的排布
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    return self.attrsArray;
}

/**
 * 返回indexPath位置cell对应的布局属性
 */
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    // 创建布局属性
    UICollectionViewLayoutAttributes *attr = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    // 设置布局属性的frame
    //横向布局时width 、height数值互换
    //横向布局时有时需要去除nav加状态栏高度
    CGFloat contentWidth = self.isHorizon ? self.collectionView.frame.size.width : self.collectionView.frame.size.height - kOffset;
    
    CGFloat width = (contentWidth - kEdgeInsets.left - kEdgeInsets.right - (kColumnCount - 1) * kColumnMargin) / kColumnCount;
    CGFloat height = [self.delegate waterFlowLayout:self
                                          itemWidth:width
                                          indexPath:indexPath
                                     collectionView:self.collectionView];
    // 找出高度最短的那一列/行
    NSInteger readyInsertColumn = 0;
    CGFloat minColumnHeight = [self.columnHeights[0] doubleValue];
    for (NSInteger i = 1; i < kColumnCount; i++) {
        // 取得第i列/行的高度
        CGFloat columnHeight = [self.columnHeights[i] doubleValue];
        if (minColumnHeight > columnHeight) {
            minColumnHeight = columnHeight;
            readyInsertColumn = i;
        }
    }
    //横竖匹配
    CGFloat x = self.isHorizon ? kEdgeInsets.left + readyInsertColumn * (width + kColumnMargin) : minColumnHeight;
    CGFloat y = self.isHorizon ? minColumnHeight :kEdgeInsets.left + readyInsertColumn * (width + kColumnMargin);
    if (self.isHorizon ? y != kEdgeInsets.top : x != kEdgeInsets.top) {
        self.isHorizon ? (y += kRowMargin) : (x += kRowMargin);
    }
    attr.frame = CGRectMake(x, y, self.isHorizon ? width:height,self.isHorizon? height : width );
    //更新最短列/行的高/长度
    self.columnHeights[readyInsertColumn] = self.isHorizon ? @(CGRectGetMaxY(attr.frame)) : @(CGRectGetMaxX(attr.frame));
    return attr;
}

- (CGSize)collectionViewContentSize{
    CGFloat length = [[self.columnHeights sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 doubleValue] < [obj2 doubleValue];
    }].firstObject doubleValue] + kEdgeInsets.bottom;
    return CGSizeMake(self.isHorizon ? 0 : length, self.isHorizon ? length : 0);
}

@end
