//
//  ZXNetWork.m
//  ZXartApp
//
//  Created by mac  on 2018/3/14.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "ZXNetWork.h"

@interface ZXNetWork ()

@end

@implementation ZXNetWork

+ (void)sendRequest:(HTTPType)httpType
                api:(NSString *)api
             params:(id)params
    completeHandler:(CompleteHandler)completeHandler {
    [self sendRequest:httpType
                  api:api
               params:params
      progressHandler:nil
      completeHandler:completeHandler];
}

+ (void)sendRequest:(HTTPType)httpType
                api:(NSString *)api
             params:(id)params
    progressHandler:(ProgressingHandler)progressHandler
    completeHandler:(CompleteHandler)completeHandler {
    [self sendRequest:httpType
                  api:api
               params:params
           headerType:HTTPHeaderTypeNone
           headerInfo:nil
          requestType:RequestSerializerRAW
       progressHandler:progressHandler
      completeHandler:completeHandler];
}

+ (void)sendRequest:(HTTPType)httpType
                api:(NSString *)api
             params:(id)params
         headerType:(HTTPHeaderType)headerType
    progressHandler:(ProgressingHandler)progressHandler
    completeHandler:(CompleteHandler)completeHandler {
    [self sendRequest:httpType
                  api:api
               params:params
           headerType:headerType
           headerInfo:nil
          requestType:RequestSerializerJSON
      progressHandler:progressHandler
      completeHandler:completeHandler];
}

+ (void)sendRequest:(HTTPType)httpType
                api:(NSString *)api
             params:(id)params
         headerType:(HTTPHeaderType)headerType
         headerInfo:(NSDictionary *)headerInfo
        requestType:(RequestSerializerType)requestType
    progressHandler:(ProgressingHandler)progressHandler
    completeHandler:(CompleteHandler)completeHandler {
    
    [[NetworkCenter center] sendRequest:^(NetworkRequest *request) {
        request.requestType    = ZXRequestTypeNormal;
        request.httpType   = httpType;
        request.baseAPI    = api;
        request.parameters = params;
        request.headerType = headerType;
        request.requestSerializerType = requestType;
        if (request.headerType == HTTPHeaderTypeOther) {
            request.headerInfo = headerInfo;
        }
        else if (request.headerType == HTTPHeaderTypeNone) {
            request.headerInfo = nil;
        }
        else {
            request.headerInfo = [self getHeaderInfo:request.headerType];
        }
    } progress:^(int64_t bytesRead, int64_t totalBytes) {
        if (progressHandler) {
            progressHandler(bytesRead, totalBytes);
        }
    } complete:^(id returnData, id error) {
        if (error) {
            if ([error isKindOfClass:[NSString class]] && ([error isEqualToString:@"Request failed: unauthorized (401)"] || [error isEqualToString:@"Request failed: bad request (400)"]) && ![api isEqualToString:@"https://webapi.zxart.cn/token"]) {
                // If it failed because of the unsued Token, then we have to regain the token.
//                [[UserDataControl sharedDataControl] fetchUserTokenWithCompleteHandler:^(id data, RequestComplteCode completeCode, NSString *errorMessage) {
//                    if (completeCode == RequestComplteCodeSuccess) {
//                        // After regain Token succefully, start over
//                        [self sendRequest:httpType api:api params:params headerType:headerType headerInfo:headerInfo requestType:requestType progressHandler:^(int64_t bytesRead, int64_t totalBytes) {
//                            if (progressHandler) {
//                                progressHandler(bytesRead, totalBytes);
//                            }
//                        } completeHandler:^(id returnData, id error) {
//                            if (completeHandler) {
//                                completeHandler(returnData, error);
//                            }
//                        }];
//                    }
//                    else {
//                        if (completeHandler) {
//                            completeHandler(nil, errorMessage);
//                        }
//                    }
//                }];
            }
            else {
                if (completeHandler) {
                    completeHandler(nil, error);
                }
            }
        }
        else {
            if (completeHandler) {
                completeHandler(returnData, error);
            }
        }
    }];
}

+ (void)uploadRequest:(FileType)dataType
                  api:(NSString *)api
                 data:(NSData *)data
        progressHandler:(ProgressingHandler)progressHandler
      completeHandler:(CompleteHandler)completeHandler {
    [self uploadRequest:dataType
                    api:api
                   data:data
               dataName:nil
        progressHandler:progressHandler
        completeHandler:completeHandler];
}

+ (void)uploadRequest:(FileType)dataType
                  api:(NSString *)api
                 data:(NSData *)data
             dataName:(NSString *)dataName
      progressHandler:(ProgressingHandler)progressHandler
      completeHandler:(CompleteHandler)completeHandler {
    [self uploadRequest:dataType
                    api:api
                   data:data
               dataName:dataName
             headerType:HTTPHeaderTypeNone
             headerInfo:nil
        progressHandler:progressHandler
        completeHandler:completeHandler];
}

+ (void)uploadRequest:(FileType)dataType
                  api:(NSString *)api
                 data:(NSData *)data
             dataName:(NSString *)dataName
           headerType:(HTTPHeaderType)headerType
           headerInfo:(NSDictionary *)headerInfo
      progressHandler:(ProgressingHandler)progressHandler
      completeHandler:(CompleteHandler)completeHandler {
    [[NetworkCenter center] sendRequest:^(NetworkRequest *request) {
        request.requestType    = ZXRequestTypeUpload;
        request.httpType       = HTTPTypePOST;
        request.baseAPI        = api;
        request.parameters     = nil;
        request.headerType     = HTTPHeaderTypeToken;
        request.timeout        = 40.0;
        if (request.headerType == HTTPHeaderTypeOther) {
            request.headerInfo = headerInfo;
        }
        else if (request.headerType == HTTPHeaderTypeNone) {
            request.headerInfo = nil;
        }
        else {
            request.headerInfo = [self getHeaderInfo:request.headerType];
        }
        request.uploadDataType = dataType;
        request.uploadData     = data;
        request.uploadDataName = dataName;
        request.timeout        = 50;
    } complete:^(id returnData, id error) {
        if (!error) {
            if (completeHandler) {
                completeHandler(returnData, error);
            }
        }
        else {
            if ([error isKindOfClass:[NSString class]] && ([error isEqualToString:@"Request failed: unauthorized (401)"] || [error isEqualToString:@"Request failed: bad request (400)"])) {
                // If it failed because of the unsued Token, then we have to regain the token.
//                [[UserDataControl sharedDataControl] fetchUserTokenWithCompleteHandler:^(id data, RequestComplteCode completeCode, NSString *errorMessage) {
//                    if (completeCode == RequestComplteCodeSuccess) {
//                        // After regain Token succefully, start over
//                        [self uploadRequest:dataType api:api data:data dataName:dataName headerType:headerType headerInfo:headerInfo progressHandler:^(int64_t bytesRead, int64_t totalBytes) {
//                            if (progressHandler) {
//                                progressHandler(bytesRead, totalBytes);
//                            }
//                        } completeHandler:^(id returnData, id error) {
//                            if (completeHandler) {
//                                completeHandler(returnData, error);
//                            }
//                        }];
//                    }
//                    else {
//                        if (completeHandler) {
//                            completeHandler(nil, errorMessage);
//                        }
//                    }
//                }];
            }
            else {
                if (completeHandler) {
                    completeHandler(nil, error);
                }
            }
        }
    }];
}

/**
 *  下载文件
 */
+ (void)downloadDataWithApi:(NSString *)api
              progressBlock:(ProgressingHandler)progressBlock
              completeBlock:(DownLoadCompletionBLock)completeBlock {
    [self downloadDataWithApi:api
          downloadDestination:nil
                progressBlock:progressBlock
                completeBlock:completeBlock];
}

/**
 *  下载文件到指定目录
 */
+ (void)downloadDataWithApi:(NSString *)api
        downloadDestination:(NSString *)downloadDestination
              progressBlock:(ProgressingHandler)progressBlock
              completeBlock:(DownLoadCompletionBLock)completeBlock {
    [[NetworkCenter center] sendRequest:^(NetworkRequest *request) {
        request.requestType    = ZXRequestTypeDownload;
        request.httpType       = HTTPTypePOST;
        request.baseAPI        = api;
        request.timeout        = 50;
        request.downloadDestination = downloadDestination;
    } progress:^(int64_t bytesRead, int64_t totalBytes) {
        if (progressBlock) {
            progressBlock(bytesRead, totalBytes);
        }
    } complete:^(id returnData, id error) {
        if (!error) {
            if (completeBlock) {
                completeBlock(returnData, error);
            }
        }
        else {
            if (completeBlock) {
                completeBlock(nil, error);
            }
        }
    }];
}

/**
 *  取消下载
 */
+ (void)cancelDownLoad {
    [[NetworkCenter center] cancelDownload];
}

#pragma mark - Private Method
+ (void)request:(ZXRequestType)zxRequestType
       httpType:(HTTPType)httpType
            api:(NSString *)api
         params:(id)params
           data:(id)data
     headerType:(HTTPHeaderType)headerType
     headerInfo:(NSDictionary *)headerInfo
    requestType:(RequestSerializerType)requestType
    progressHandler:(ProgressingHandler)progressHandler
    completeHandler:(CompleteHandler)completeHandler {
    
}

+ (NSDictionary *)getHeaderInfo:(HTTPHeaderType)httpInfo {
    switch (httpInfo) {
        case HTTPHeaderTypeAuthen:
            return @{@"Value" : @"",@"Field" : @"Authorization"};
            break;
        case HTTPHeaderTypeToken:
            return @{@"Value" : [NSString stringWithFormat:@"bearer %@",@""],@"Field" : @"Authorization"};
            break;
        default:
            return nil;
            break;
    }
}


@end
