//
//  ZXTabsScrollViewController.m
//  EasyHome
//
//  Created by mac on 2018/9/30.
//  Copyright © 2018 黄勤炜. All rights reserved.
//

#import "ZXTabsScrollViewController.h"
#import "ZXNavigationController.h"
#import <Masonry.h>
@interface ZXTabsScrollViewController ()<UIScrollViewDelegate>
@end

@implementation ZXTabsScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _baseTag = 100;
}


- (void)setupTabsWithTitleArray:(NSArray *)titleArray{
    WeakSelf(weakSelf)
    _titleScrollView = [[ZXTitleScrollView alloc] initWithTitles:titleArray selected:nil];
    [self.view addSubview:_titleScrollView];
    [_titleScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(weakSelf.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(weakSelf.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(weakSelf.view).offset(NAVBAR_HEIGHT);
        }
        make.height.equalTo(@(50));
    }];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delaysContentTouches = NO;
    [self.view addSubview:scrollView];
    scrollView.backgroundColor = [UIColor whiteColor];
    self.scrollView = scrollView;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.titleScrollView.mas_bottom);
        make.left.right.equalTo(weakSelf.view);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(weakSelf.view.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.equalTo(weakSelf.view);
        }
    }];
    [self.view bringSubviewToFront:_titleScrollView];
    
    [self setupListWithTitleArray:titleArray];
}


- (void)setupListWithTitleArray:(NSArray *)titleArray{
    WeakSelf(weakSelf)
    [titleArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.tag = idx + weakSelf.baseTag;
        tableView.backgroundColor = [UIColor whiteColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.estimatedRowHeight = 44.0;
        tableView.showsVerticalScrollIndicator = NO;
        tableView.showsHorizontalScrollIndicator = NO;
        [weakSelf.scrollView addSubview:tableView];
    }];
    
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * _scrollView.subviews.count, 0);
    
    [_scrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakSelf.titleScrollView.mas_bottom);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.left.equalTo(weakSelf.scrollView).offset(SCREEN_WIDTH * idx);
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(weakSelf.view.mas_safeAreaLayoutGuideBottom);
            } else {
                make.bottom.equalTo(weakSelf.view);
            }
        }];
    }];
    ZXNavigationController *navController = (ZXNavigationController *)self.navigationController;
    if([navController isKindOfClass:[ZXNavigationController class]])[_scrollView.panGestureRecognizer requireGestureRecognizerToFail:[navController screenEdgePanGestureRecognizer]];
}

#pragma mark scrollView 代理

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:_scrollView]) {
        int contentoffset = scrollView.contentOffset.x;
        int numOfTable = contentoffset/SCREEN_WIDTH;
        if(_titleScrollView.currentPage == numOfTable)return;
        [_titleScrollView topBtnClick:numOfTable];
        [self scrollToPage:numOfTable];
    }
}

- (void)scrollToPage:(NSInteger)page{
    ZXLog(@"请复写页面滚动方法%ld",(long)page);
}

- (NSArray *)tabsArray{
    return _scrollView.subviews;
}

@end
