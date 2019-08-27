//
//  ZXartTools.h
//  ZXartApp
//
//  Created by Apple on 16/8/8.
//  Copyright © 2016年 Apple. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ZXUtilHelper : NSObject

/**
 获得单个汉子横向实际显示像素
 */
+ (CGFloat)getSingleChineseSringWidth:(UIFont *)font;
/**
 计算字符串横向实际显示像素（根据字体）
 */
+ (CGFloat)computeString:(NSString *)string baseFont:(UIFont *)font;
/**
 根据长度填充 空格 字符 ，超过填充 换行 字符
 */
+ (NSString *)fillUpSpace:(NSString *)string lineFeedWidth:(CGFloat)width baseFont:(UIFont *)font;
/**
 根据长度填充 任意 字符 ，超过填充 换行 字符
 */
+ (NSString *)fillUpString:(NSString *)string lineFeedWidth:(CGFloat)width baseFont:(UIFont *)font fill:(NSString *)fill;
/**
 获取APP信息
 */
+(void)hs_updateWithAPPID:(NSString *)appid block:(void(^)(NSString *releaseNotes,NSString *storeVersion, NSString *openUrl,BOOL isUpdate))block;
+ (NSString *)getAppName;
+ (NSString *)getAppVersion;
+ (NSString *)getAppBuildVersion;


/**
 随机生成6位验证码

 */
+ (NSString *)ramVcode;

/**
 弹出选择栏
 */
+ (void)showActionSheetWithTitle:(NSString *)title
                         message:(NSString *)message
                         actions:(NSArray<UIAlertAction *>*)actions
                  viewController:(id)viewController
                         present:(void (^)(void))present;

+ (BOOL)callPhone:(NSString *)phone;

#pragma mark - ********************文件数据
/**
 解析JSONdata为数组/字典
 */
+ (id)encodeJson:(NSData *)jsonData;
/**
 查询文件、文件夹大小
 */
- (NSString *)fileSizeAtPath:(NSString *)filePath;
/**
 删除文件、文件夹
 */
- (void)deleteFolderAtPath:(NSString *)folderPath
                 extension:(NSString *)fileExtension;

#pragma mark - ********************图片相关
/**
 获得二维码
 */
+ (UIImage *)createEcodeImageFromString:(NSString *)string
                                   size:(CGFloat)size;
/**
 图片压缩质量
 */
+ (UIImage *)reduceImage:(UIImage *)image
                 percent:(float)percent;
/**
 图片压缩大小
 */
+ (UIImage*)imageWithImageSimple:(UIImage*)image
                    scaledToSize:(CGSize)newSize;
/**
 视图截图
 */
+ (UIImage *)screenshotOfView:(UIView *)view;

#pragma mark - ********************layer
/**
 图层加线
 */
+ (void)addLayerBorder:(UIView *)view
                 width:(CGFloat)borderWidth
                 color:(UIColor *)borderColor;


#pragma mark - ********************提示权限
+ (void)showPhotoAlbumAccessDenied;
+ (void)showCameraAccessDenied;

@end
