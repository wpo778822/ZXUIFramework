//
//  UIImage+Util.m
//  ZXartApp
//
//  Created by mac  on 2017/9/8.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "UIImage+Util.h"
#import <YYImage.h>
#import <YYWebImage.h>
@implementation UIImage (Util)

+ (UIImage *)QRCodeWithStr:(NSString *)qrStr size:(CGFloat)size {
    // 1. 实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2. 恢复滤镜的默认属性
    [filter setDefaults];
    // 3. 将字符串转换成NSData
    qrStr = [qrStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSData *data = [qrStr dataUsingEncoding:NSUTF8StringEncoding];
    // 4. 通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKey:@"inputMessage"];
    // 5. 获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    // 6. 将CIImage转换成UIImage，并放大显示
    
    // 7.将CIImage转成UIImage
    UIImage *image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:size];
    return image;
}

- (NSString *)fetchQRCode {
    __block NSString *messageString = nil;
        CIDetector *detector     = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        CIImage *ciImage         = [CIImage imageWithCGImage:self.CGImage];
        NSArray *features        = [detector featuresInImage:ciImage];
        if (features.count >= 1) {
            //结果对象
            CIQRCodeFeature *feature = [features objectAtIndex:0];
            messageString            = feature.messageString;
        }
    return messageString;
}

+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size  {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width           = CGRectGetWidth(extent) * scale;
    size_t height          = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs     = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context     = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    CGColorSpaceRelease(cs);
    UIImage *simage        = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    
    return simage;
}

+ (NSData *)compressImageData:(NSData *)imageData intoFormat:(ImageFormat)imageFormat imageSize:(CGSize)imageSize imageQuality:(CGFloat)imageQuality {
    UIImage *image = [UIImage imageWithData:imageData];
    return [self compressImage:image intoFormat:imageFormat imageSize:imageSize imageQuality:imageQuality];
}

+ (NSData *)compressImage:(UIImage *)image intoFormat:(ImageFormat)imageFormat imageSize:(CGSize)imageSize imageQuality:(CGFloat)imageQuality {
    CGFloat scale = 0.0;
    CGFloat width = imageSize.width >0 ? imageSize.width:960;
    UIImage *resizeImage;
    if (image.size.height > image.size.width && image.size.width > width) {
        scale       = width / image.size.width;
        resizeImage = [image yy_imageByResizeToSize:CGSizeMake(width, scale * image.size.height)];
    }
    else if (image.size.width > image.size.height && image.size.height > width) {
        scale       = width / image.size.height;
        resizeImage = [image yy_imageByResizeToSize:CGSizeMake(scale * image.size.width, width)];
    }
    else {
        resizeImage = image;
    }
    
    NSData *imageData = [resizeImage convertToType:imageFormat quality:imageQuality];
    return imageData;
}

- (UIImage *)resizeTo:(CGSize)size {
    return [self yy_imageByResizeToSize:size];
}

- (NSData *)convertToType:(ImageFormat)imageFormat quality:(CGFloat)quality {
    YYImageType type = YYImageTypeJPEG;
    switch (imageFormat) {
        case ImageFormatJPEG: {
            type = YYImageTypeJPEG;
            break;
        }
        case ImageFormatWEBP: {
            type = YYImageTypeWebP;
            break;
        }
    }
    
    YYImageEncoder *jpegEncoder = [[YYImageEncoder alloc] initWithType:type];
    jpegEncoder.quality         = quality;
    [jpegEncoder addImage:self duration:0];
    NSData *imageData           = [jpegEncoder encode];
    return imageData;
}

+ (NSString *)convertData:(NSData *)imageData{
    NSString *result = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return result;
}

- (UIImage*)imageAddCornerWithRadius:(CGFloat)radius andSize:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)];
    CGContextAddPath(ctx,path.CGPath);
    CGContextClip(ctx);
    [self drawInRect:rect];
    CGContextDrawPath(ctx, kCGPathFillStroke);
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)fixOrientation
{
    
    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height, CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
