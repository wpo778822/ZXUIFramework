//
//  ZXartTools.m
//  ZXartApp
//
//  Created by Apple on 16/8/8.
//  Copyright © 2016年 Apple. All rights reserved.
//


#import "ZXUtilHelper.h"
@implementation ZXUtilHelper

+ (NSString *)ramVcode{
    int num                = (arc4random() % 1000000);
    NSString *randomNumber = [NSString stringWithFormat:@"%.6d",num];
    return randomNumber;
}

+ (CGFloat)getSingleChineseSringWidth:(UIFont *)font{
    return [self computeString:@"中" baseFont:font];
}

+ (CGFloat)computeString:(NSString *)string baseFont:(UIFont *)font{
    UILabel *label = [UILabel new];
    label.font = font;
    label.text = string;
    [label sizeToFit];
    return label.frame.size.width;
}

+ (NSString *)fillUpSpace:(NSString *)string lineFeedWidth:(CGFloat)width baseFont:(UIFont *)font{
   return [ZXUtilHelper fillUpString:string lineFeedWidth:width baseFont:font fill:@" "];
}

+ (NSString *)fillUpString:(NSString *)string lineFeedWidth:(CGFloat)width baseFont:(UIFont *)font fill:(NSString *)fill{
    NSString *space = @"";
    UILabel *label = [UILabel new];
    label.font = font;
    label.text = fill;
    [label sizeToFit];
    CGFloat bWidth = width;//间隔空间，超过直接折行
    CGFloat sWidth = label.frame.size.width;
    label.text = string;
    [label sizeToFit];
    CGFloat oWidth = label.frame.size.width;
    if (oWidth > bWidth) {
        space = @"\n";
    }else{
        for (NSInteger i = 0; i < MAX(0, (bWidth - oWidth) / sWidth); i++) {
            space = [space stringByAppendingString:fill];
        }
    }
    return space;
}

#pragma mark - 拨打电话

+ (BOOL)callPhone:(NSString *)phone{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phone]];
    if ([[UIApplication sharedApplication] canOpenURL:url] && phone) {
        [[UIApplication sharedApplication] openURL:url];
        return YES;
    }
    return NO;
}

#pragma mark - 弹出信息
+ (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                         actions:(NSArray<UIAlertAction *> *)actions
                  viewController:(id)viewController
                         present:(void (^)(void))present{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    [actions enumerateObjectsUsingBlock:^(UIAlertAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [alertController addAction:obj];
    }];
    void (^block)(void) = ^{
        [viewController presentViewController:alertController animated:YES completion:present];
    };
    dispatch_async(dispatch_get_main_queue(), block);
}

#pragma mark - 文件数据

+ (id)encodeJson:(NSData *)jsonData{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        return nil;
    }
}

- (NSString *)fileSizeAtPath:(NSString*)filePath{
    unsigned long long fileSizeFigure = 0;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSDictionary *attrs = [manager attributesOfItemAtPath:filePath error:nil];
    if (![manager fileExistsAtPath:filePath]) return 0;
    if ([attrs.fileType isEqualToString:NSFileTypeDirectory]) {
        NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:filePath] objectEnumerator];
        NSString* fileName;
        while ((fileName = [childFilesEnumerator nextObject]) != nil){
            NSString* fileAbsolutePath = [filePath stringByAppendingPathComponent:fileName];
            fileSizeFigure += [manager attributesOfItemAtPath:fileAbsolutePath error:nil].fileSize;
        }
        return [self returnSizeStringAtSizeFigure:fileSizeFigure];
    }else{
        fileSizeFigure = attrs.fileSize;
        return [self returnSizeStringAtSizeFigure:fileSizeFigure];
    }
}

- (NSString *)returnSizeStringAtSizeFigure:(unsigned long long)sizeFigure{
    NSString *fileSizeText = nil;
    if (sizeFigure >= pow(10, 9)) { // size >= 1GB
        fileSizeText = [NSString stringWithFormat:@"%.2fGB", sizeFigure / pow(10, 9)];
    } else if (sizeFigure >= pow(10, 6)) { // 1GB > size >= 1MB
        fileSizeText = [NSString stringWithFormat:@"%.2fMB", sizeFigure / pow(10, 6)];
    } else if (sizeFigure >= pow(10, 3)) { // 1MB > size >= 1KB
        fileSizeText = [NSString stringWithFormat:@"%.2fKB", sizeFigure / pow(10, 3)];
    } else { // 1KB > size
        fileSizeText = [NSString stringWithFormat:@"%lluB", sizeFigure];
    }
    return fileSizeText;
}

#pragma mark - 删除文件夹

- (void)deleteFolderAtPath:(NSString *)folderPath
                 extension:(NSString *)fileExtension{
    NSString *extension = fileExtension;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *fileContents = [fileManager contentsOfDirectoryAtPath:folderPath error:NULL];
    NSEnumerator *childFilesEnumerator = [fileContents objectEnumerator];
    NSString *filename;
    while ((filename = [childFilesEnumerator nextObject])) {
        if (extension == nil) {
            [fileManager removeItemAtPath:[folderPath stringByAppendingPathComponent:filename] error:NULL];
        }else{
            if ([[filename pathExtension] isEqualToString:extension]) {
                [fileManager removeItemAtPath:[folderPath stringByAppendingPathComponent:filename] error:NULL];
            }
        }
    }
}

#pragma mark - 图层加圆角
#pragma mark - 视图加线

+ (void)addLayerBorder:(UIView *)view
                 width:(CGFloat)borderWidth
                 color:(UIColor *)borderColor{
    [[view layer] setBorderWidth:borderWidth];
    [[view layer] setBorderColor:borderColor.CGColor];
}

#pragma mark - 检查版本号

+(void)hs_updateWithAPPID:(NSString *)appid block:(void(^)(NSString *releaseNotes,NSString *storeVersion,NSString *openUrl, BOOL isUpdate))block{
    NSString *currentVersion = [self getAppVersion];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/cn/lookup?id=%@",appid]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            NSDictionary *appInfoDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
            NSDictionary *dic =  appInfoDic[@"results"][0];
            NSString *appStoreVersion = dic[@"version"];
            if ([appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedDescending){
                block(dic[@"releaseNotes"],appStoreVersion,[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", appid],YES);
            }else if ([appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedSame){
                block(dic[@"releaseNotes"],appStoreVersion,[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", appid],NO);
            }else if ([appStoreVersion compare:currentVersion options:NSNumericSearch] == NSOrderedAscending){
                block(dic[@"releaseNotes"],appStoreVersion,[NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@?ls=1&mt=8", appid],NO);
            }
        }else{
            return ;
        }
    }] resume];
}

+ (NSString *)getAppName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}

+ (NSString *)getAppVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+ (NSString *)getAppBuildVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

#pragma mark -图片处理
+ (UIImage *)createEcodeImageFromString:(NSString *)string
                                   size:(CGFloat)size{
    // 1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2. 恢复滤镜的默认属性
    [filter setDefaults];
    // 3. 将字符串转换成NSData
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 4. 通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    // 5. 获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    // 6. 将CIImage转换成UIImage，并放大显示
    
    // 7.将CIImage转成UIImage

    CGRect extent = CGRectIntegral(outputImage.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:outputImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    UIImage *image = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return image;
}

//压缩图片质量
+ (UIImage *)reduceImage:(UIImage *)image percent:(float)percent{
    NSData *imageData = UIImageJPEGRepresentation(image, percent);
    UIImage *newImage = [UIImage imageWithData:imageData];
    return newImage;
}
//压缩图片尺寸
+ (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//截图
+ (UIImage *)screenshotOfView:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, 0.0);
    
    if ([view respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
        [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    }
    else{
        [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


#pragma mark - ********************提示权限
+ (void)showPhotoAlbumAccessDenied{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相册读取失败" message:@"需要打开应用对相册的访问权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];

}

+ (void)showCameraAccessDenied{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"相机调用失败" message:@"需要打开应用对摄像头的访问权限" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:dismissAction];
    [alertController addAction:settingsAction];
    
    [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
}



@end
