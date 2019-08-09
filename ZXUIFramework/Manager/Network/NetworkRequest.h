//
//  NetworkRequest.h
//  ZXartApp
//
//  Created by mac  on 2018/3/14.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkConst.h"

@interface NetworkRequest : NSObject

// upload/download/request
@property (nonatomic, assign) ZXRequestType          requestType;

// HTTP header Type
@property (nonatomic, assign) HTTPHeaderType         headerType;

// HTTP header Info
@property (nonatomic,   copy) NSDictionary           *headerInfo;

// HTTP Type: get/post/delete
@property (nonatomic, assign) HTTPType               httpType;

@property (nonatomic, assign) RequestSerializerType  requestSerializerType;

@property (nonatomic, assign) ResponseSerializerType responseSerializerType;

@property (nonatomic,   copy) NSString               *baseAPI;

@property (nonatomic,   copy) id                     parameters;

@property (nonatomic, assign) NSTimeInterval         timeout;

@property (nonatomic, assign) NSInteger              retryCounts;

@property (nonatomic, assign) NSInteger              currentRetryCounts;

@property (nonatomic,   copy) NSString               *uploadDataName;

@property (nonatomic, assign) FileType               uploadDataType;

@property (nonatomic, strong) NSData                 *uploadData;

@property (nonatomic,   copy) NSString               *downloadDestination;
@end

