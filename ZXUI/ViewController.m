//
//  ViewController.m
//  ZXUI
//
//  Created by mac on 2018/10/10.
//  Copyright © 2018 mac. All rights reserved.
//

#import "ViewController.h"
#import "ZXGestureLockView.h"
#import "ZXPhotoPicker.h"
#import "ZXHUDHelper.h"
@interface ViewController ()<ZXGestureLockViewDelegate,ZXPhotoPickerViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ZXGestureLockView *gestureLockView = [[ZXGestureLockView alloc]initWithFrame:CGRectZero];
    gestureLockView.delegate = self;
    gestureLockView.frame = CGRectMake(0, 0, 200, 200);
    gestureLockView.center = self.view.center;
    [self.view addSubview:gestureLockView];
}

- (BOOL)didSelectedGestureLockView:(ZXGestureLockView *)gestureLockView pathNumberStr:(NSString *)pathNumberStr{
    NSLog(@"%@",pathNumberStr);
//    [ZXHUDHelper tipMessage:pathNumberStr];
    [ZXHUDHelper progress:.8];
//    [self presentPhotoPickerWithPathNumberStr:pathNumberStr];
//    [[CTMediator sharedInstance] CTMediator_showAlertWithMessage:@"casa" cancelAction:nil confirmAction:^(NSDictionary *info) {
//        NSLog(@"%@",info);
//    }];
//    [[CTMediator sharedInstance] showPhotoBrowserWithPhotos:@[@"https://developers.weixin.qq.com/miniprogram/dev/image/cat/0.jpg?t=18102614",@"https://developers.weixin.qq.com/miniprogram/dev/image/cat/0.jpg?t=18102614"] singleTapedAction:^(NSDictionary *info) {
//        NSLog(@"%@",info);
//        UIViewController *viewController = info[@"viewController"];
//        if ([viewController isKindOfClass:[UIViewController class]]) {
//            [viewController dismissViewControllerAnimated:YES completion:nil];
//        }
//        [[CTMediator sharedInstance] releaseCachedTargetWithTargetName:@"A"];
//    } longPressedAction:^(NSDictionary *info) {
//        NSLog(@"%@",info);
//    } quitAction:^(NSDictionary *info) {
//        NSLog(@"%@",info);
//    }];
    return YES;
}


- (void)presentPhotoPickerWithPathNumberStr:(NSString *)pathNumberStr{
    if (pathNumberStr.length > 1) {
        // Custom selection number
        ZXPhotoPickerViewController *pickerViewController = [[ZXPhotoPickerViewController alloc] init];
        pickerViewController.numberOfPhotoToSelect = pathNumberStr.length;
        
        UIColor *customColor = [UIColor colorWithRed:248.0/255.0 green:217.0/255.0 blue:44.0/255.0 alpha:1.0];
        
        pickerViewController.theme.titleLabelTextColor = [UIColor blackColor];
        pickerViewController.theme.navigationBarTintColor = customColor;
        pickerViewController.theme.tintColor = [UIColor blackColor];
        pickerViewController.theme.orderTintColor = customColor;
        pickerViewController.theme.orderLabelTextColor = [UIColor blackColor];
        pickerViewController.theme.cameraVeilColor = customColor;
        pickerViewController.theme.cameraIconColor = [UIColor whiteColor];
        pickerViewController.theme.statusBarStyle = UIStatusBarStyleDefault;
        
        [self zx_presentCustomAlbumPhotoView:pickerViewController delegate:self];
    }
    else {
        [[ZXPhotoPickerTheme sharedInstance] reset];
        [self zx_presentAlbumPhotoViewWithDelegate:self];
    }
}


#pragma mark - YMSPhotoPickerViewControllerDelegate

- (void)photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:(ZXPhotoPickerViewController *)picker
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow photo album access?", nil) message:NSLocalizedString(@"Need your permission to access photo albumbs", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)photoPickerViewControllerDidReceiveCameraAccessDenied:(ZXPhotoPickerViewController *)picker
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Allow camera access?", nil) message:NSLocalizedString(@"Need your permission to take a photo", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    
    // The access denied of camera is always happened on picker, present alert on it to follow the view hierarchy
    [picker presentViewController:alertController animated:YES completion:nil];
}

- (void)photoPickerViewController:(ZXPhotoPickerViewController *)picker didFinishPickingImage:(UIImage *)image
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        NSLog(@"%@",image);
    }];
}

- (void)photoPickerViewController:(ZXPhotoPickerViewController *)picker didFinishPickingImages:(NSArray *)photoAssets
{
    [picker dismissViewControllerAnimated:YES completion:^() {
        
//        PHImageManager *imageManager = [[PHImageManager alloc] init];
//        
//        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
//        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
//        options.networkAccessAllowed = YES;
//        options.resizeMode = PHImageRequestOptionsResizeModeExact;
//        options.synchronous = YES;
//        
//        NSMutableArray *mutableImages = [NSMutableArray array];
//        
//        for (PHAsset *asset in photoAssets) {
//            CGSize targetSize = CGSizeMake(500,500);
//            [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage *image, NSDictionary *info) {
//                [mutableImages addObject:image];
//            }];
//        }
//        NSLog(@"%@",mutableImages);
    }];
}


@end
