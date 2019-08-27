//
//  ZXLocationShowController.m
//  EasyHome
//
//  Created by 黄勤炜 on 2018/6/27.
//  Copyright © 2018年 黄勤炜. All rights reserved.
//
#define BOTTOM_BAR_HEIGHT 90

#define TAG_LOCATION_ME_NEAR 1
#define TAG_LOCATION_ME_FAR 2

#import "ZXLocationShowController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "ZXUtilHelper.h"
#import <MapKit/MapKit.h>
@interface ZXLocationShowController()<MAMapViewDelegate,AMapSearchDelegate,AMapSearchDelegate>
@property (nonatomic, strong) MAMapView              *mapView;
@property (nonatomic, strong) AMapSearchAPI          *searchAPI;
@property (nonatomic, strong) UILabel                *topLabel;
@property (nonatomic, strong) UILabel                *bottomLabel;
@property (nonatomic, strong) UIButton               *locationBtn;
@property (nonatomic, strong) MAAnnotationView       *userLocationAnnotationView;
@property (nonatomic, assign) BOOL                   locationPermissionGranted;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;
@property (nonatomic, copy  ) NSString               *locationDes;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, copy) NSArray *pathPolylines;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSUInteger countDownTime;

@end

@implementation ZXLocationShowController{
    BOOL isBackToUserLocation;
    BOOL hasInitMapView;
}

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - BOTTOM_BAR_HEIGHT - TABBAR_OFFSET)];
        _mapView.delegate = self;
        _mapView.mapType = MAMapTypeStandard;
        _mapView.zoomEnabled = YES;
        _mapView.minZoomLevel = 4;
        _mapView.maxZoomLevel = 18;
        
        _mapView.scrollEnabled = YES;
        _mapView.showsCompass = NO;
        
        _mapView.logoCenter = CGPointMake(SCREEN_WIDTH - 3 - _mapView.logoSize.width/2, CGRectGetHeight(self.mapView.frame) - 3 - _mapView.logoSize.height/2);
        
        _mapView.showsScale = YES;
        _mapView.scaleOrigin = CGPointMake(12, CGRectGetHeight(_mapView.frame) - 25);
    }
    return _mapView;
}

- (AMapSearchAPI *)searchAPI{
    if (!_searchAPI) {
        _searchAPI = [[AMapSearchAPI alloc] init];
        _searchAPI.delegate = self;
    }
    return _searchAPI;
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self releaseTimer];
    [self endUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navBarBgAlpha = @"0.0";
    
    if (!hasInitMapView) {
        if (_coordinate2D.latitude > 0.f) {
            [self showLocation];
        }else{
            [self getLocation];
        }
    }
}

- (void)showLocation{
    hasInitMapView = YES;
    [self.mapView setZoomLevel:17.0 animated:NO];
    [self.mapView setCenterCoordinate:_coordinate2D animated:NO];
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = _coordinate2D;
    [self.mapView addAnnotation:pointAnnotation];
    [self startUpdatingLocation];
    WeakSelf(weakSelf)
    GCDTime(0.5, ^{
        [weakSelf driving];
    });
}

- (void)getLocation{
    AMapGeocodeSearchRequest *searchRequest = [[AMapGeocodeSearchRequest alloc] init];
    searchRequest.address = _locationDes;
    //发起正向地理编码
    [self.searchAPI AMapGeocodeSearch: searchRequest];
}

- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response{
    if (response.geocodes.count == 0) {
        return;
    }
    NSArray *locationInfo = response.geocodes; // 用户位置信息
    AMapGeocode *geocode = locationInfo.firstObject;
    AMapGeoPoint *geoPoint = geocode.location;
    _coordinate2D.latitude = geoPoint.latitude;
    _coordinate2D.longitude = geoPoint.longitude;
    [self showLocation];
}


- (void)startCountDown {
    [self releaseTimer];
    _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)releaseTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)countDown {
    if (--_countDownTime > 0) {
        [self checkAuthorization];
    }
    else {
        [self releaseTimer];
        _countDownTime = 60;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"";
    [self.view addSubview:self.mapView];
    _countDownTime = 60;

    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;

    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[self getImage:@"barbuttonicon_back_cube"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    [leftButton sizeToFit];
    leftButton.imageEdgeInsets = UIEdgeInsetsMake(0, -13, 0, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];

    _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_locationBtn setBackgroundImage:[self getImage:@"location_my"] forState:UIControlStateNormal];
    [_locationBtn setBackgroundImage:[self getImage:@"location_my_HL"] forState:UIControlStateHighlighted];
    _locationBtn.tag = TAG_LOCATION_ME_FAR;
    [_locationBtn sizeToFit];
    CGRect frame;
    frame = _locationBtn.frame;
    frame.origin.x = SCREEN_WIDTH - 13 - CGRectGetWidth(frame);
    frame.origin.y = CGRectGetMaxY(_mapView.frame) - 18 - 50;
    _locationBtn.frame = frame;
    [self.view addSubview:_locationBtn];
    [_locationBtn addTarget:self action:@selector(backToUserLocation) forControlEvents:UIControlEventTouchUpInside];


    UIView *locationView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - BOTTOM_BAR_HEIGHT - TABBAR_OFFSET, SCREEN_WIDTH, BOTTOM_BAR_HEIGHT)];
    locationView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:locationView];

    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setBackgroundImage:[self getImage:@"locationSharing_navigate_icon_new"] forState:UIControlStateNormal];
    [shareBtn setBackgroundImage:[self getImage:@"locationSharing_navigate_icon_HL_new"] forState:UIControlStateHighlighted];
    [shareBtn addTarget:self  action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    [shareBtn sizeToFit];
    frame = shareBtn.frame;
    frame.origin.x = SCREEN_WIDTH - 13 - CGRectGetWidth(frame);
    frame.origin.y = (CGRectGetHeight(locationView.frame) - CGRectGetHeight(frame))/2;
    shareBtn.frame = frame;
    [locationView addSubview:shareBtn];

    _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 25, CGRectGetMinX(shareBtn.frame) -13 - 29 , 50)];
    _topLabel.font = UIFontWithSize(SCALE_SET(20));
    _topLabel.numberOfLines = 2;
    _topLabel.textColor = [UIColor blackColor];
    _topLabel.textAlignment = NSTextAlignmentLeft;
    [locationView addSubview:_topLabel];
    _topLabel.text = _locationDes;

    isBackToUserLocation = NO;

    NSArray<UIGestureRecognizer *> *gestureRecognizers = self.mapView.subviews[0].gestureRecognizers;
    for (UIGestureRecognizer *gestureRecognizer in gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] && self.navigationController.interactivePopGestureRecognizer) {
            [gestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
            break;
        }
    }

    [self checkAuthorization];
}

- (void)showMap:(double)longtitude latidue:(double)latitude address:(NSString *)address {
    _coordinate2D = CLLocationCoordinate2DMake(latitude, longtitude);
    _locationDes = address;
}

- (void)share{
    NSMutableArray *actions = @[].mutableCopy;
    WeakSelf(weakSelf)
    UIAlertAction *action0 = [UIAlertAction actionWithTitle:@"重新规划" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf driving];
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"使用苹果地图导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf navigationFromCurrentLocationToLocationUsingAppleMap:weakSelf.coordinate2D destinationName:weakSelf.locationDes];
    }];
    [actions addObject:action0];
    [actions addObject:action1];
    [actions addObject:action2];
    BOOL gaodeMapCanOpen = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]];
    
    if (gaodeMapCanOpen) {
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"使用高德地图导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [weakSelf navigationUsingGaodeMapFromLocation:weakSelf.mapView.userLocation.location.coordinate toLocation:weakSelf.coordinate2D destinationName:weakSelf.locationDes];
        }];
        [actions addObject:action3];
    }
    
    [ZXUtilHelper showActionSheetWithTitle:nil message:nil actions:actions viewController:self present:nil];
}

//跳转苹果地图
-(void)navigationFromCurrentLocationToLocationUsingAppleMap:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName {
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(toCoordinate2D.latitude, toCoordinate2D.longitude);
    MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:loc addressDictionary:nil]];
    [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                   launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                   MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
}

//跳转高德地图
-(void)navigationUsingGaodeMapFromLocation:(CLLocationCoordinate2D)fromCoordinate2D toLocation:(CLLocationCoordinate2D)toCoordinate2D destinationName:(NSString *)destinationName {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Name = [infoDictionary objectForKey:@"CFBundleName"];
    NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=%@&sid=BGVIS1&slat=%f&slon=%f&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0",app_Name, fromCoordinate2D.latitude, fromCoordinate2D.longitude, toCoordinate2D.latitude, toCoordinate2D.longitude, destinationName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
}

- (void)locationError{
    ZXLog(@"%@",LOCATION_AUTHORIZATION_DENIED_TEXT);
}


//规划路线
- (void)driving{
    if (self.mapView.userLocation.location.coordinate.latitude == 0) {
        [self.mapView setCenterCoordinate:_coordinate2D  animated:YES];
        return;
    }
    AMapDrivingRouteSearchRequest *request = [[AMapDrivingRouteSearchRequest alloc] init];
    //设置起点，我选择了当前位置，mapView有这个属性
    request.origin = [AMapGeoPoint locationWithLatitude:self.mapView.userLocation.location.coordinate.latitude longitude:self.mapView.userLocation.location.coordinate.longitude];
    //设置终点，可以选择手点
    request.destination = [AMapGeoPoint locationWithLatitude:_coordinate2D.latitude longitude:_coordinate2D.longitude];
    
    //发起路径搜索，发起后会执行代理方法
    [_search AMapDrivingRouteSearch: request];
}

//实现路径搜索的回调函数
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response{
    if(response.route == nil){
        return;
    }
    if (response.count > 0){
        //移除地图原本的遮盖
        [_mapView removeOverlays:_pathPolylines];
        _pathPolylines = nil;
        // 只显⽰示第⼀条 规划的路径
        _pathPolylines = [self polylinesForPath:response.route.paths[0]];
        //添加新的遮盖，然后会触发代理方法进行绘制
        [_mapView addOverlays:_pathPolylines];
        [_mapView showOverlays:_pathPolylines animated:YES];
    }
}

//绘制遮盖时执行的代理方法
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    /* 自定义定位精度对应的MACircleView. */
    
    //画路线
    if ([overlay isKindOfClass:[MAPolyline class]]){
        //初始化一个路线类型的view
        MAPolylineRenderer *polygonView = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        //设置线宽颜色等
        polygonView.lineWidth = 8.f;
        polygonView.strokeColor = [UIColor colorWithRed:0.015 green:0.658 blue:0.986 alpha:1.000];
        polygonView.fillColor = [UIColor colorWithRed:0.940 green:0.771 blue:0.143 alpha:0.800];
        //返回view，就进行了添加
        return polygonView;
    }
    return nil;
    
}

- (NSArray *)polylinesForPath:(AMapPath *)path{
    if (path == nil || path.steps.count == 0)
    {
        return nil;//如果path=nil或者导航路段数为零
    }
    NSMutableArray *polylines = [NSMutableArray array];
    [path.steps enumerateObjectsUsingBlock:^(AMapStep *step, NSUInteger idx, BOOL *stop) {
        NSUInteger count = 0;
        CLLocationCoordinate2D *coordinates = [self coordinatesForString:step.polyline coordinateCount:&count parseToken:@";"];
        //根据经纬度坐标数据生成多段线
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:coordinates count:count];
        [polylines addObject:polyline];
        (void)(free(coordinates)), coordinates = NULL;
    }];
    return polylines;
}

- (CLLocationCoordinate2D *)coordinatesForString:(NSString *)string coordinateCount:(NSUInteger *)coordinateCount parseToken:(NSString *)token{
    if (string == nil)
    {
        return NULL;
    }
    if (token == nil)
    {
        token = @",";
    }
    NSString *str = @"";
    if (![token isEqualToString:@","])
    {
        str = [string stringByReplacingOccurrencesOfString:token withString:@","];
    }
    else
    {
        str = [NSString stringWithString:string];
    }
    NSArray *components = [str componentsSeparatedByString:@","];
    NSUInteger count = [components count] / 2;
    if (coordinateCount != NULL)
    {
        *coordinateCount = count;
    }
    CLLocationCoordinate2D *coordinates = (CLLocationCoordinate2D*)malloc(count * sizeof(CLLocationCoordinate2D));
    
    for (int i = 0; i < count; i++)
    {
        coordinates[i].longitude = [[components objectAtIndex:2 * i]     doubleValue];
        coordinates[i].latitude  = [[components objectAtIndex:2 * i + 1] doubleValue];
    }
    return coordinates;
}




#pragma mark - 按钮回调

- (void)back:(UIButton *)btn {
    PopVC
}

#pragma mark - 权限管理

- (void)checkAuthorization {
    if (![CLLocationManager locationServicesEnabled]) {
        self.locationPermissionGranted = NO;
    }else {
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        switch (status) {
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted:
                self.locationPermissionGranted = NO;
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                if (_timer)[self releaseTimer];
                self.locationPermissionGranted = YES;
                [self driving];
                break;
            case kCLAuthorizationStatusNotDetermined:
                if (!_timer) {
                    [self startCountDown];
//                    [self startUpdatingLocation];
                }
                break;
        }
    }

}

- (BOOL)locationPermissionGranted{
    if (!_locationPermissionGranted) {
        [self locationError];
    }
    return _locationPermissionGranted;
}



- (void)setLocationButtonStyle:(BOOL)isLocationMeNear {
    NSInteger targetTag = isLocationMeNear ? TAG_LOCATION_ME_NEAR : TAG_LOCATION_ME_FAR;
    if (_locationBtn.tag != targetTag) {
        NSString *backgroundImageString =  isLocationMeNear ? @"location_my_current": @"location_my";
        [_locationBtn setBackgroundImage:[self getImage:backgroundImageString] forState:UIControlStateNormal];
    }

}

#pragma mark - 更新地图
- (void)startUpdatingLocation {
    _mapView.distanceFilter = 10;
    _mapView.desiredAccuracy = kCLLocationAccuracyBest;
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    MAUserLocationRepresentation *representation = [[MAUserLocationRepresentation alloc] init];
    representation.showsHeadingIndicator = YES;
    [_mapView updateUserLocationRepresentation:representation];
}

- (void)endUpdatingLocation {
    self.mapView.userTrackingMode = MAUserTrackingModeNone;
    self.mapView.showsUserLocation = NO;
    [self.mapView removeOverlays:self.mapView.overlays];
    [self.mapView removeAnnotations:self.mapView.annotations];
    self.mapView.delegate = nil;
}

- (void)backToUserLocation{
    if (!self.locationPermissionGranted) return;
    isBackToUserLocation = YES;
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate  animated:YES];
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (animated && isBackToUserLocation) {
        isBackToUserLocation = NO;
        [self setLocationButtonStyle:YES];
    }else {
        [self setLocationButtonStyle:NO];
    }
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views{
    for (MAAnnotationView *view in views) {
        if ([view.annotation isKindOfClass:[MAUserLocation class]]){
            MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
            pre.fillColor = [UIColor colorWithRed:30/255.0 green:130/255.0 blue:233/255.0 alpha:0.3];
            pre.image = [self getImage:@"locationSharing_Icon_MySelf"];
            pre.lineWidth = 0;
            pre.showsAccuracyRing = YES;
            pre.showsHeadingIndicator = YES;

            UIImage *indicator = [self getImage:@"locationSharing_Icon_Myself_Heading"];
            UIImageView *headingView = [[UIImageView alloc] initWithImage:indicator];
            [headingView sizeToFit];
            CGRect frame = headingView.frame;
            frame.origin.x = 1;
            frame.origin.y = -8;
            headingView.frame = frame;

            [view addSubview:headingView];
            [self.mapView updateUserLocationRepresentation:pre];

            view.canShowCallout = NO;
            self.userLocationAnnotationView = view;

            break;
        }
    }

}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (!updatingLocation && self.userLocationAnnotationView != nil){
        [UIView animateWithDuration:0.1 animations:^{
            double degree = userLocation.heading.trueHeading;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
        }];
    }
}

- (UIImage *)getImage:(NSString *)imageName{
   return [UIImage imageNamed:imageName inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:@"/ZXResource.bundle"]] compatibleWithTraitCollection:nil];
}
@end
