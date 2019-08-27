//
//  ReturnImagesCell.h
//  ZXartApp
//
//  Created by blingman on 2018/5/11.
//  Copyright © 2018年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZXAddImageCellDelegate <NSObject>

@optional;
- (void)refreshReturnImagesCell;

@end

static NSString * const ReturnImagesCellIdentifier = @"ReturnImagesCellIdentifier";

@interface ZXAddImageCell : UITableViewCell

@property (nonatomic, strong)NSMutableArray * imageArray;
@property (nonatomic, weak)id<ZXAddImageCellDelegate> delegate;
- (void)configEHomeTypeWithIndex:(NSInteger)index title:(NSString *)title;
- (void)configSubViewCanEdit:(BOOL)canEdit title:(NSString *)title maxImageCount:(NSInteger)maxImageCount maxRowCount:(NSInteger)maxRowCount;

@end
