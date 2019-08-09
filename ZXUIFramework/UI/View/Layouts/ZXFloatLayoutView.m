//
//  ZXFloatLayoutView.m
//  ZXartApp
//
//  Created by Apple on 2018/1/7.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import "ZXFloatLayoutView.h"

#define ValueSwitchAlignLeftOrRight(valueLeft, valueRight) (self.contentMode == UIViewContentModeRight ? valueRight : valueLeft)

const CGSize ZXFloatLayoutViewAutomaticalMaximumItemSize = {-1.0, -1.0};

@implementation ZXFloatLayoutView

- (instancetype)init{
    self = [super init];
    if (self) {
        self.contentMode = UIViewContentModeLeft;
        self.minimumItemSize = CGSizeZero;
        self.maximumItemSize = ZXFloatLayoutViewAutomaticalMaximumItemSize;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat contentWidth = [UIScreen mainScreen].bounds.size.width - self.margins.left - self.margins.right;
    CGSize floatLayoutViewSize = [self layoutSubviewsWithSize:CGSizeMake(contentWidth, CGFLOAT_MAX)];
    self.frame = CGRectMake(self.margins.left, self.margins.top, contentWidth, floatLayoutViewSize.height);
}

- (CGSize)layoutSubviewsWithSize:(CGSize)size{
   __block CGPoint itemViewOrigin = CGPointMake(ValueSwitchAlignLeftOrRight(self.padding.left, size.width - self.padding.right), self.padding.top);
   __block CGFloat currentRowMaxY = itemViewOrigin.y;
    CGSize maximumItemSize = CGSizeEqualToSize(self.maximumItemSize, ZXFloatLayoutViewAutomaticalMaximumItemSize) ? CGSizeMake(size.width - self.padding.left - self.padding.right, size.height - self.padding.top - self.padding.bottom) : self.maximumItemSize;

    [self.subviews enumerateObjectsUsingBlock:^(UIView *itemView, NSUInteger idx, BOOL * _Nonnull stop) {
        CGSize itemViewSize = [itemView sizeThatFits:maximumItemSize];
        itemViewSize = CGSizeMake(MIN(maximumItemSize.width, MAX(self.minimumItemSize.width, itemViewSize.width)), MIN(maximumItemSize.height, MAX(self.minimumItemSize.height, itemViewSize.height)));
        BOOL shouldBreakline = idx == 0 ? YES : ValueSwitchAlignLeftOrRight(itemViewOrigin.x + self.itemMargins.left + itemViewSize.width + self.padding.right > size.width,
                                                                          itemViewOrigin.x - self.itemMargins.right - itemViewSize.width - self.padding.left < 0);
        if (shouldBreakline) {
            if (CGRectEqualToRect(itemView.frame, CGRectZero)) {
                itemView.frame = CGRectMake(ValueSwitchAlignLeftOrRight(self.padding.left, size.width - self.padding.right - itemViewSize.width), currentRowMaxY, itemViewSize.width, itemViewSize.height);
            }
            itemViewOrigin.x = ValueSwitchAlignLeftOrRight(self.padding.left + itemViewSize.width + self.itemMargins.right, size.width - self.padding.right - itemViewSize.width - self.itemMargins.left);
            itemViewOrigin.y = currentRowMaxY;
        } else {
            if (CGRectEqualToRect(itemView.frame, CGRectZero)) {
                itemView.frame = CGRectMake(ValueSwitchAlignLeftOrRight(itemViewOrigin.x + self.itemMargins.left, itemViewOrigin.x - self.itemMargins.right - itemViewSize.width), itemViewOrigin.y, itemViewSize.width, itemViewSize.height);
            }
            itemViewOrigin.x = ValueSwitchAlignLeftOrRight(itemViewOrigin.x + self.itemMargins.left + self.itemMargins.right + itemViewSize.width,
                                                           itemViewOrigin.x - itemViewSize.width - self.itemMargins.left - self.itemMargins.right);
        }
        currentRowMaxY = MAX(currentRowMaxY, itemViewOrigin.y + self.itemMargins.top + self.itemMargins.bottom + itemViewSize.height);
    }];
    
    currentRowMaxY -= self.itemMargins.top;
    currentRowMaxY -= self.itemMargins.bottom;
    CGSize resultSize = CGSizeMake(size.width, currentRowMaxY + self.padding.bottom);
    return resultSize;
}

@end
