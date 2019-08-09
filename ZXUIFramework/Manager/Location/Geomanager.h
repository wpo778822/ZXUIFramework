//
//  Geomanager.h
//  ZXartApp
//
//  Created by mac  on 2018/7/11.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <MAMapKit/MAMapKit.h>

typedef void (^SearchCompletionBlock)(AMapGeocodeSearchResponse *response);

@interface Geomanager : NSObject
+ (Geomanager *)manager;
+ (void)fetchCurrrentLocationCompletionBlock:(AMapLocatingCompletionBlock)completionBlock;
+ (void)fetchCurrrentLocationWithoutReGeocodeCompletionBlock:(AMapLocatingCompletionBlock)completionBlock;
+ (void)geocodeSearchAddress:(NSString *)address completionBlock:(SearchCompletionBlock)completionBlock;
+ (CGFloat)distanceBetweenMapPoints:(CLLocationCoordinate2D)pointA pointB:(CLLocationCoordinate2D)pointB;

+ (BOOL)gaodeMapCanOpen;
+ (BOOL)baiduMapCanOpen;
+ (BOOL)qqMapCanOpen;
//国测标准
//跳转苹果地图导航
+(void)navigationFromCurrentLocationToLocationUsingAppleMap:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName;
//跳转高德地图导航
+(void)navigationUsingGaodeMapToLocation:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName;
//跳转百度地图
+(void)navigationUsingBaiduMapToLocation:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName;
//跳转腾讯地图
+(void)navigationUsingQQMapToLocation:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName;
@end
