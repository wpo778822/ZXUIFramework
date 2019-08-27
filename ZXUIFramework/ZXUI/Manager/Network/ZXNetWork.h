//
//  ZXNetWork.h
//  ZXartApp
//
//  Created by mac  on 2018/3/14.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkCenter.h"
#import "NetworkConst.h"


@interface ZXNetWork : NSObject

#pragma mark - Request
/**
发送普通请求
 */
+ (void)sendRequest:(HTTPType)httpType
                api:(NSString *)api
             params:(id)params
    completeHandler:(CompleteHandler)completeHandler;

+ (void)sendRequest:(HTTPType)httpType
                api:(NSString *)api
             params:(id)params
    progressHandler:(ProgressingHandler)progressHandler
    completeHandler:(CompleteHandler)completeHandler;

/**
 *  发送带Token/Authen header请求
 */
+ (void)sendRequest:(HTTPType)httpType
                api:(NSString *)api
             params:(id)params
         headerType:(HTTPHeaderType)headerType
    progressHandler:(ProgressingHandler)progressHandler
    completeHandler:(CompleteHandler)completeHandler;

/**
 *  发送自定义请求
 */
+ (void)sendRequest:(HTTPType)httpType
                api:(NSString *)api
             params:(id)params
         headerType:(HTTPHeaderType)headerType
         headerInfo:(NSDictionary *)headerInfo
        requestType:(RequestSerializerType)requestType
    progressHandler:(ProgressingHandler)progressHandler
    completeHandler:(CompleteHandler)completeHandler;

#pragma mark - Upload
/**
 *  上传
 */
+ (void)uploadRequest:(FileType)dataType
                  api:(NSString *)api
                 data:(NSData *)data
      progressHandler:(ProgressingHandler)progressHandler
      completeHandler:(CompleteHandler)completeHandler;

+ (void)uploadRequest:(FileType)dataType
                  api:(NSString *)api
                 data:(NSData *)data
             dataName:(NSString *)dataName
      progressHandler:(ProgressingHandler)progressHandler
      completeHandler:(CompleteHandler)completeHandler;

+ (void)uploadRequest:(FileType)dataType
                  api:(NSString *)api
                 data:(NSData *)data
             dataName:(NSString *)dataName
           headerType:(HTTPHeaderType)headerType
           headerInfo:(NSDictionary *)headerInfo
      progressHandler:(ProgressingHandler)progressHandler
      completeHandler:(CompleteHandler)completeHandler;

#pragma mark - Download
/**
 *  下载文件
 */
+ (void)downloadDataWithApi:(NSString *)api
                             progressBlock:(ProgressingHandler)progressBlock
                             completeBlock:(DownLoadCompletionBLock)completeBlock;

/**
 *  下载文件到指定目录
 */
+ (void)downloadDataWithApi:(NSString *)api
        downloadDestination:(NSString *)downloadDestination
              progressBlock:(ProgressingHandler)progressBlock
              completeBlock:(DownLoadCompletionBLock)completeBlock;

/**
 *  取消下载
 */
+ (void)cancelDownLoad;


#pragma mark - Special


@end
