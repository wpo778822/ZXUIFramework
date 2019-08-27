//
//  Geomanager.m
//  ZXartApp
//
//  Created by mac  on 2018/7/11.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "Geomanager.h"
#import <MapKit/MapKit.h>
@interface Geomanager () <AMapSearchDelegate>
@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) AMapSearchAPI *searchAPI;
@property (nonatomic, copy) SearchCompletionBlock completionBlock;
@end

@implementation Geomanager

+ (Geomanager *)manager{
    static Geomanager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (void)fetchCurrrentLocationCompletionBlock:(AMapLocatingCompletionBlock)completionBlock{
    [[self manager].locationManager requestLocationWithReGeocode:YES completionBlock:completionBlock];
}

+ (void)fetchCurrrentLocationWithoutReGeocodeCompletionBlock:(AMapLocatingCompletionBlock)completionBlock{
    [[self manager].locationManager requestLocationWithReGeocode:NO completionBlock:completionBlock];
}

+ (void)geocodeSearchAddress:(NSString *)address completionBlock:(SearchCompletionBlock)completionBlock{
    AMapGeocodeSearchRequest *searchRequest = [[AMapGeocodeSearchRequest alloc] init];
    searchRequest.address = address;
    //发起正向地理编码
    [[self manager].searchAPI AMapGeocodeSearch:searchRequest];
    [self manager].completionBlock = completionBlock;
}


- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
    if(_completionBlock)_completionBlock(response);
}

- (AMapLocationManager *)locationManager{
    if (!_locationManager) {
        _locationManager = [[AMapLocationManager alloc]init];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        //   定位超时时间，最低2s，此处设置为2s
        _locationManager.locationTimeout = 2;
        //   逆地理请求超时时间，最低2s，此处设置为2s
        _locationManager.reGeocodeTimeout = 2;
    }
    return _locationManager;
}

- (AMapSearchAPI *)searchAPI{
    if (!_searchAPI) {
        _searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
    }
    return _searchAPI;
}

+ (CGFloat)distanceBetweenMapPoints:(CLLocationCoordinate2D)pointA pointB:(CLLocationCoordinate2D)pointB{
    MAMapPoint point1 = MAMapPointForCoordinate(pointA);
    MAMapPoint point2 = MAMapPointForCoordinate(pointB);
    //2.计算距离
    return MAMetersBetweenMapPoints(point1,point2);
}
+ (BOOL)gaodeMapCanOpen{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
}
+ (BOOL)baiduMapCanOpen{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
}
+ (BOOL)qqMapCanOpen{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"qqmap://"]];
}

+(void)navigationFromCurrentLocationToLocationUsingAppleMap:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName{
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(toCoordinate2D.latitude, toCoordinate2D.longitude);
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:loc addressDictionary:nil]];
    toLocation.name = destinationName;
    [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                   launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                   MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
}

+(void)navigationUsingGaodeMapToLocation:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&sname=我的位置&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",app_Name,toCoordinate2D.latitude, toCoordinate2D.longitude,destinationName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
}

+(void)navigationUsingBaiduMapToLocation:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    NSString *urlString = [[NSString stringWithFormat:@"baidumap://map/direction?origin={{我的位置}}&destination=%f,%f&mode=driving&coord_type=gcj02&src=%@", toCoordinate2D.latitude, toCoordinate2D.longitude,app_Name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
}

+(void)navigationUsingQQMapToLocation:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    NSString *urlString = [[NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&from=我的位置&tocoord=%f,%f&referer=%@", toCoordinate2D.latitude, toCoordinate2D.longitude,app_Name] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
}


@end
