//
//  ZXSinglePhotoViewController.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ZXSinglePhotoViewController.h"

#import "ZXPhotoPickerTheme.h"

typedef NS_ENUM(NSUInteger, PresentationStyle) {
    PresentationStyleDefault,
    PresentationStyleDark
};

@interface ZXSinglePhotoViewController ()

@property (nonatomic, copy) void (^dismissalHandler)(BOOL);
@property (nonatomic, strong) PHAsset *currentAsset;
@property (nonatomic, weak) PHImageManager *imageManager;
@property (nonatomic, weak) IBOutlet UIImageView *photoImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *imageContainerView;
@property (nonatomic, assign) PresentationStyle presentationStyle;

@end

@implementation ZXSinglePhotoViewController

- (instancetype)initWithPhotoAsset:(PHAsset *)asset imageManager:(PHImageManager *)manager dismissalHandler:(void (^)(BOOL))dismissalHandler{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        self.currentAsset = asset;
        self.dismissalHandler = dismissalHandler;
        self.imageManager = manager;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
    navigationItem.leftBarButtonItem =
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss:)];
    navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(selectCurrentPhoto:)];
    
    self.navigationItem.leftBarButtonItem = navigationItem.leftBarButtonItem;
    self.navigationItem.rightBarButtonItem = navigationItem.rightBarButtonItem;

    if (![[ZXPhotoPickerTheme sharedInstance].navigationBarTintColor isEqual:[UIColor whiteColor]]) {
        [self.navigationController.navigationBar setShadowImage:[UIImage new]];
        self.navigationController.navigationBar.barTintColor = [ZXPhotoPickerTheme sharedInstance].navigationBarTintColor;
    }

    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize imageSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) * scale, (CGRectGetHeight([UIScreen mainScreen].bounds) - CGRectGetHeight(self.navigationController.navigationBar.bounds)) * scale);

    CGSize targetSize = CGSizeMake(imageSize.width * scale, imageSize.height * scale);
    [self.imageManager requestImageForAsset:self.currentAsset targetSize:targetSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        self.photoImageView.image = result;
    }];

    self.navigationController.hidesBarsOnTap = YES;
    [self.navigationController.barHideOnTapGestureRecognizer addTarget:self action:@selector(switchPresentationStyle:)];
    
    self.presentationStyle = PresentationStyleDefault;
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return [ZXPhotoPickerTheme sharedInstance].statusBarStyle;
}

#pragma mark - IBActions

- (void)dismiss:(id)sender{
    if (self.dismissalHandler) {
        self.dismissalHandler(NO);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectCurrentPhoto:(id)sender{
    if (self.dismissalHandler) {
        self.dismissalHandler(YES);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)switchPresentationStyle:(id)sender{
    [UIView animateWithDuration:0.15 animations:^{
        self.view.backgroundColor = self.presentationStyle == PresentationStyleDefault ? [UIColor blackColor] : [UIColor whiteColor];
    } completion:^(BOOL finished) {
        self.presentationStyle = self.presentationStyle == PresentationStyleDefault ?PresentationStyleDark : PresentationStyleDefault;
    }];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.photoImageView;
}

@end
