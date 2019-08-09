//
//  ImageManger.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/8/10.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//

#import "ImageManger.h"
#import "UIImage+Util.h"
@implementation ImageManger
+ (NSString *)convertImage:(UIImage *)image{
   return [UIImage convertData:[UIImage compressImage:image intoFormat:ImageFormatJPEG imageSize:CGSizeZero imageQuality:0.75]];
}
@end
