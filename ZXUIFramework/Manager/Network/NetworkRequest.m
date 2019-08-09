//
//  NetworkRequest.m
//  ZXartApp
//
//  Created by mac  on 2018/3/14.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "NetworkRequest.h"


@implementation NetworkRequest

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeout = 20;
        _retryCounts = 5;
        _currentRetryCounts = 0;
        _requestSerializerType = RequestSerializerJSON;
    }
    return self;
}
@end

