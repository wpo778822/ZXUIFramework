//
//  UIColor+ColorExtension.m
//  ZXartApp
//
//  Created by mac  on 2016/12/24.
//  Copyright © 2016年 Apple. All rights reserved.
//

#import "UIColor+ColorCategory.h"

#define DEFAULT_VOID_COLOR [UIColor whiteColor]

@implementation UIColor (ColorCategory)

#pragma mark - Public Method
+ (UIColor *)colorUsingRed:(CGFloat)red
                     Green:(CGFloat)green
                      Blue:(CGFloat)blue {
    return [UIColor theRed:red
                  theGreen:green
                   theBlue:blue
                     alpha:1.0];
}

+ (UIColor *)colorUsingRed:(CGFloat)red
                     Green:(CGFloat)green
                      Blue:(CGFloat)blue
                     Alpha:(CGFloat)alpha {
    return [UIColor theRed:red
                  theGreen:green
                   theBlue:blue
                     alpha:alpha];
}

+ (UIColor *)colorUsingHexString:(NSString *)hexString
                           alpah:(CGFloat)alpha {
    return [self colorWithHexString:hexString
                              Alpah:alpha];
}

+ (UIColor *)colorUsingHexString:(NSString *)hexString {
    return [self colorWithHexString:hexString
                              Alpah:1.0f];
}

+ (UIColor *)randomColor {
    CGFloat randomRed   = arc4random() % 255;
    CGFloat randomGreen = arc4random() % 255;
    CGFloat randomBlue  = arc4random() % 255;
    return [UIColor colorUsingRed:randomRed
                            Green:randomGreen
                             Blue:randomBlue];
}

+ (UIColor *)randomColorUsingHSB {
    CGFloat randomHue        = arc4random() % 100 / 100.0;
    CGFloat randomSaturation = arc4random() % 100  / 100.0;
    CGFloat randomBrightness = arc4random() % 100 / 100.0;
    return [UIColor colorWithHue:randomHue
                      saturation:randomSaturation
                      brightness:randomBrightness
                           alpha:1.0];
}

+ (UIColor *)randomColorUsingHSBWithSBLocked {
    CGFloat randomHue  = arc4random() % 100  / 100.0;
    CGFloat saturation = 0.3;
    CGFloat brightness = 1.0;
    return [UIColor colorWithHue:randomHue
                      saturation:saturation
                      brightness:brightness
                           alpha:1.0];
}

#pragma mark - Private Method
+ (UIColor *)theRed:(CGFloat)red
           theGreen:(CGFloat)green
            theBlue:(CGFloat)blue
              alpha:(CGFloat)alpha {
    return [UIColor colorWithRed: red / 255.0f
                           green: green / 255.0f
                            blue: blue / 255.0f
                           alpha: alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
                          Alpah:(CGFloat)alpha {
    
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6)
        return DEFAULT_VOID_COLOR;
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return DEFAULT_VOID_COLOR;
    
    NSRange range;
    range.location    = 0;
    range.length      = 2;
    NSString *rString = [cString substringWithRange:range];

    range.location    = 2;
    NSString *gString = [cString substringWithRange:range];

    range.location    = 4;
    NSString *bString = [cString substringWithRange:range];

    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor theRed:r
                  theGreen:g
                   theBlue:b
                     alpha:alpha];
}

- (UIImage *)createImageWithRect:(CGRect)rect roundedCornersSize:(CGFloat)cornerRadius{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return cornerRadius > 0.f ? [self imageWithRoundedCornersSize:cornerRadius originalImage:resultImage] : resultImage;
}

- (UIImage *)imageWithRoundedCornersSize:(CGFloat)cornerRadius originalImage:(UIImage *)original{
    CGRect frame = CGRectMake(0, 0, original.size.width, original.size.height);
    UIGraphicsBeginImageContextWithOptions(original.size, NO, 1.0);
    [[UIBezierPath bezierPathWithRoundedRect:frame
                                cornerRadius:cornerRadius] addClip];
    [original drawInRect:frame];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
