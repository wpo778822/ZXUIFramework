//
//  UIViewController+ZXPhotoHelper.m
//  ZXartApp
//
//  Created by 黄勤炜 on 2018/7/4.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "UIViewController+ZXPhotoHelper.h"

#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

#import "ZXPhotoNavigationController.h"

@implementation UIViewController (ZXPhotoHelper)

- (void)photoPickerProcessing:(id<UIImagePickerControllerDelegate,UINavigationControllerDelegate>)delegate {
    if ([delegate isKindOfClass:[ZXPhotoPickerViewController class]]) {
        ZXPhotoPickerViewController *pickerViewController = (ZXPhotoPickerViewController *)delegate;
        if ([pickerViewController.delegate respondsToSelector:@selector(photoPickerViewControllerDidReceiveCameraAccessDenied:)]) {
            [pickerViewController.delegate photoPickerViewControllerDidReceiveCameraAccessDenied:pickerViewController];
        }
    }
}

- (void)imagePickerProcessing:(id<UIImagePickerControllerDelegate,UINavigationControllerDelegate>)delegate{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = delegate;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)zx_presentCameraCaptureViewWithDelegate:(id<UIImagePickerControllerDelegate, UINavigationControllerDelegate>)delegate{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
            case AVAuthorizationStatusAuthorized:
                [self imagePickerProcessing:delegate];
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                [self photoPickerProcessing:delegate];
                break;
            case AVAuthorizationStatusNotDetermined:
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                    dispatch_async(dispatch_get_main_queue(), ^() {
                        granted ? [self imagePickerProcessing:delegate] : [self photoPickerProcessing:delegate];
                    });
                }];
                break;
        }
    }
    else {
        // 不支持摄像头
    }
}

- (void)zx_presentAlbumPhotoViewWithDelegate:(id<ZXPhotoPickerViewControllerDelegate>)delegate{
    [self zx_presentCustomAlbumPhotoView:[[ZXPhotoPickerViewController alloc] init] delegate:delegate];
}

- (void)zx_presentCustomAlbumPhotoView:(ZXPhotoPickerViewController *)pickerViewController delegate:(id<ZXPhotoPickerViewControllerDelegate>)delegate{
    ZXPhotoNavigationController *navigationController = [[ZXPhotoNavigationController alloc] initWithRootViewController:pickerViewController];
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    [self authProcessing:delegate navigationController:navigationController pickerViewController:pickerViewController status:status];
}

- (void)authProcessing:(id<ZXPhotoPickerViewControllerDelegate>)delegate navigationController:(ZXPhotoNavigationController *)navigationController pickerViewController:(ZXPhotoPickerViewController *)pickerViewController status:(PHAuthorizationStatus)status {
    
    __weak __typeof__(self) weakSelf = self;
    
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            pickerViewController.delegate = delegate;
            [self presentViewController:navigationController animated:YES completion:nil];
            break;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
            if ([delegate respondsToSelector:@selector(photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:)]) {
                [delegate photoPickerViewControllerDidReceivePhotoAlbumAccessDenied:pickerViewController];
            }
            break;
        case PHAuthorizationStatusNotDetermined:
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                dispatch_async(dispatch_get_main_queue(), ^() {
                    [weakSelf authProcessing:delegate navigationController:navigationController pickerViewController:pickerViewController status:status];
                });
            }];
            break;
    }
}


@end
