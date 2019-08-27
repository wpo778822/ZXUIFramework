//
//  ZXOptionButton.h
//  XYLQ
//
//  Created by mac on 2018/8/17.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ZXOptionButton;

@protocol ZXOptionButtonDelagate <NSObject>
- (void)beginShowOptionListWithOptionButton:(ZXOptionButton *)optionButton;
- (void)didSelectRow:(NSInteger)row optionButton:(ZXOptionButton *)optionButton;

@end
@interface ZXOptionButton : UIView

@property (nonatomic, strong) UIFont *optionTitleFont;
@property (nonatomic, strong) UIColor *placeholderColor;

@property (nonatomic, strong) UIColor *selectTitleColor;

@property (nonatomic, copy) NSArray *titleArray;

@property (nonatomic, copy) NSString *selectTitle;

@property (nonatomic, copy) NSString *placeholder;

@property (nonatomic, assign) BOOL showSearchBar;

@property (nonatomic, assign) NSTextAlignment textAlignment;

@property(nonatomic, assign) id<ZXOptionButtonDelagate> delegate;

@end

NS_ASSUME_NONNULL_END
