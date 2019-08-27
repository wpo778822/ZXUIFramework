//
//  ZXNetWorkManager.m
//  ZXartApp
//
//  Created by mac  on 2018/3/14.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "NetworkCenter.h"

@implementation NetworkCenter

+ (instancetype)center {
    static NetworkCenter *center = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[self alloc] init];
    });
    return center;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _service = [NetworkService sharedManager];
    }
    return self;
}

- (void)sendRequest:(RequestBlock)requestHandler
           complete:(CompleteHandler)completeHandler {
    [self sendRequest:requestHandler progress:nil complete:completeHandler];
}

- (void)sendRequest:(RequestBlock)requestHandler
           progress:(ProgressingHandler)progressBlock
           complete:(CompleteHandler)completeHandler {
    NetworkRequest *request = [[NetworkRequest alloc] init];
    if (requestHandler) {
        requestHandler(request);
    }
    [self request:request progress:progressBlock complete:completeHandler];
}

- (void)cancelDownload {
    [[NetworkService sharedManager] cancelDownload];
}
#pragma mark - Private Method
- (void)request:(NetworkRequest *)request
           progress:(ProgressingHandler)progressBlock
           complete:(CompleteHandler)completeHandler {
    [[NetworkService sharedManager] sendRequest:request progress:^(int64_t bytesRead, int64_t totalBytes) {
        if (progressBlock) {
            progressBlock(bytesRead, totalBytes);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull returnData) {
        if (completeHandler) {
            completeHandler(returnData,nil);
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull error) {
        if (completeHandler) {
            completeHandler(nil,error);
        }
    }];
}

@end
