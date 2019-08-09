//
//  ZXSuperCollectionVC.m
//  ZXartApp
//
//  Created by Apple on 2017/11/13.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "ZXSuperCollectionVC.h"

@interface ZXSuperCollectionVC ()

@end

@implementation ZXSuperCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    ZXLog(@"[%@ viewDidLoad]", NSStringFromClass([self class]));
    if (self.navigationController && ![self.navigationController.childViewControllers.firstObject isEqual:self]) {
        [self setBarButton:NO WithOriginalImage:@"tap_back" action:@selector(popBack)];
    }
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
