//
//  UITableViewController+ZXTableViewPlaceHolder.m
//  ZXartApp
//
//  Created by Apple on 2017/3/4.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "UITableView+ZXTableViewPlaceHolder.h"
#import "ZXTableViewPlaceHolderDelegate.h"

#import <objc/runtime.h>

@interface UITableView ()

@property (nonatomic, strong) UIView *placeHolderView;

@end

@implementation UITableView (ZXTableViewPlaceHolder)


- (UIView *)placeHolderView {
    return objc_getAssociatedObject(self, @selector(placeHolderView));
}

- (void)setPlaceHolderView:(UIView *)placeHolderView {
    objc_setAssociatedObject(self, @selector(placeHolderView), placeHolderView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)reloadDataAndPlaceHolder {
    [self reloadData];
    [self checkEmpty];
}

- (void)checkEmpty {
    BOOL isEmpty = YES;
    
    id<UITableViewDataSource> src = self.dataSource;
    NSInteger sections = 1;
    if ([src respondsToSelector: @selector(numberOfSectionsInTableView:)]) {
        sections = [src numberOfSectionsInTableView:self];
    }
    for (int i = 0; i < sections; ++i) {
        NSInteger rows = [src tableView:self numberOfRowsInSection:i];
        if (rows) {
            isEmpty = NO;
        }
        
    }
    if (!isEmpty != !self.placeHolderView) {
        if (isEmpty) {
            [self setPlaceHolderViewFormDelegate];
            [self addSubview:self.placeHolderView];
        } else {
            [self.placeHolderView removeFromSuperview];
            self.placeHolderView = nil;
        }
    } else if (isEmpty) {
        [self setPlaceHolderViewFormDelegate];
        [self addSubview:self.placeHolderView];
    }
}

- (void)setPlaceHolderViewFormDelegate{
    [self.placeHolderView removeFromSuperview];
    if ([self respondsToSelector:@selector(makePlaceHolderView)]) {
        self.placeHolderView = [self performSelector:@selector(makePlaceHolderView)];
    } else if ( [self.delegate respondsToSelector:@selector(makePlaceHolderView)]) {
        self.placeHolderView = [self.delegate performSelector:@selector(makePlaceHolderView)];
    }
    self.placeHolderView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
}
@end
