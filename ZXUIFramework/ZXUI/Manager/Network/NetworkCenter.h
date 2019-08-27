//
//  ZXNetWorkManager.h
//  ZXartApp
//
//  Created by mac  on 2018/3/14.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkService.h"
#import "NetworkConst.h"

@class NetworkRequest;

@interface NetworkCenter : NSObject

@property (nonatomic, strong) NetworkRequest *request;

@property (nonatomic, strong) NetworkService *service;

+ (instancetype)center;

- (void)sendRequest:(RequestBlock)requestHandler
           complete:(CompleteHandler)completeHandler;

- (void)sendRequest:(RequestBlock)requestHandler
           progress:(ProgressingHandler)progressBlock
           complete:(CompleteHandler)completeHandler;

- (void)cancelDownload;
@end

