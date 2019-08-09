//
//  ZXSuperTableVC.m
//  ZXartApp
//
//  Created by blingman on 2017/8/3.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXSuperTableVC.h"
@interface ZXSuperTableVC ()

@end

@implementation ZXSuperTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    ZXLog(@"[%@ viewDidLoad]", NSStringFromClass([self class]));
    // 默认返回按钮
    if (self.navigationController && ![self.navigationController.childViewControllers.firstObject isEqual:self]) {
        [self setBarButton:NO WithOriginalImage:@"tap_back" action:@selector(popBack)];
    }
    self.tableView.backgroundColor    = ZXGroupColor;
    self.tableView.estimatedSectionHeaderHeight = 44.0f;
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.separatorStyle     = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection    = YES;
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navBarBgAlpha = @"1.0";
}

- (void)setBarButton:(BOOL)isRight WithOriginalImage:(NSString *_Nullable)name action:(nullable SEL)action {
    UIImage *image = [[UIImage imageNamed:name] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    if (isRight) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:action];
    }else {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:action];
    }
}

- (void)popBack {
    PopVC
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    ZXLog(@"[%@ didReceiveMemoryWarning]", NSStringFromClass([self class]));
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    ZXLog(@"%@ is dealloc", NSStringFromClass([self class]));
}


@end
