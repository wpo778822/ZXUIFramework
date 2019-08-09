//
//  UIImage+Util.h
//  ZXartApp
//
//  Created by mac  on 2017/9/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ImageStr(imgStr) [UIImage imageNamed:imgStr]

typedef NS_ENUM(NSInteger,ImageFormat) {
    ImageFormatJPEG,
    ImageFormatWEBP,//yyimage
};

@interface UIImage (Util)

+ (UIImage *)QRCodeWithStr:(NSString *)qrStr size:(CGFloat)size;

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size;

+ (NSData *)compressImageData:(NSData *)imageData intoFormat:(ImageFormat)imageFormat imageSize:(CGSize)imageSize imageQuality:(CGFloat)imageQuality;

+ (NSData *)compressImage:(UIImage *)image intoFormat:(ImageFormat)imageFormat imageSize:(CGSize)imageSize imageQuality:(CGFloat)imageQuality;

- (NSString *)fetchQRCode;

- (NSData *)convertToType:(ImageFormat)imageFormat quality:(CGFloat)quality;

- (UIImage *)resizeTo:(CGSize)size;

- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size;

- (UIImage *)fixOrientation;

+ (NSString *)convertData:(NSData *)imageData;
@end
