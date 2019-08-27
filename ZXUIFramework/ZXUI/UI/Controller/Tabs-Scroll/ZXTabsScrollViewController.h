//
//  ZXTabsScrollViewController.h
//  EasyHome
//
//  Created by mac on 2018/9/30.
//  Copyright © 2018 黄勤炜. All rights reserved.
//

#import "ZXSuperVC.h"
#import "ZXTitleScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZXTabsScrollViewController : ZXSuperVC
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) ZXTitleScrollView *titleScrollView;
@property (nonatomic, assign) NSInteger baseTag;
@property (nonatomic, strong) NSArray *tabsArray;
- (void)setupTabsWithTitleArray:(NSArray *)titleArray;
- (void)scrollToPage:(NSInteger)page;

@end

NS_ASSUME_NONNULL_END
