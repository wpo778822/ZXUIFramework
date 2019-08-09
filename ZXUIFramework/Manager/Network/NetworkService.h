//
//  nNetworkService.h
//  ZXartApp
//
//  Created by mac  on 27/01/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetworkRequest.h"
#import "NetworkConst.h"

@interface NetworkService : NSObject

@property (nonatomic, assign) NSTimeInterval timeout;

/**
 *  生成单例
 */
+ (instancetype)sharedManager;

- (NSUInteger)sendRequest:(NetworkRequest *)request
                 progress:(ProgressingHandler)progressBlock
                  success:(SuccessHandler)responseSuccessBlock
                  failure:(FailHandler)responseFailBlock;

- (void)cancelDownload;

/**
 *  发送请求
 */
- (NSURLSessionTask *)sendRequest:(HTTPType)httpType
                              api:(NSString *)api
                           params:(id)params
                    progressBlock:(ProgressingHandler)progressBlock
                     successBlock:(SuccessHandler)responseSuccessBlock
                     failureBlock:(FailHandler)responseFailBlock;

/**
 *  发送带Token请求
 */
- (NSURLSessionTask *)sendRequestWithToken:(HTTPType)httpType
                                       api:(NSString *)api
                                    params:(id)params
                             progressBlock:(ProgressingHandler)progressBlock
                              successBlock:(SuccessHandler)responseSuccessBlock
                              failureBlock:(FailHandler)responseFailBlock;

/**
 *  发送带Http Header的请求
 */
- (NSURLSessionTask *)sendRequest:(HTTPType)httpType
                              api:(NSString *)api
                           params:(id)params
                   httpheaderInfo:(NSDictionary *)httpHeaderInfo
                          timeout:(NSTimeInterval)timeout
                    progressBlock:(ProgressingHandler)progressBlock
                     successBlock:(SuccessHandler)responseSuccessBlock
                     failureBlock:(FailHandler)responseFailBlock;

/**
 *  表单上传
 */
- (void)uploadFileType:(FileType)fileType
                   api:(NSString *)api
                  data:(NSData *)fileData
         progressBlock:(ProgressingHandler)progressBlock
          successBlock:(SuccessHandler)responseSuccessBlock
          failureBlock:(FailHandler)responseFailBlock;


- (void)uploadFileType:(FileType)fileType
                   api:(NSString *)api
                  data:(NSData *)fileData
              fileName:(NSString *)fileName
        httpheaderInfo:(NSDictionary *)httpHeaderInfo
               timeout:(NSTimeInterval)timeout
         progressBlock:(ProgressingHandler)progressBlock
          successBlock:(SuccessHandler)responseSuccessBlock
          failureBlock:(FailHandler)responseFailBlock;

/**
 *  下载文件
 */
- (NSURLSessionTask *)downloadFilesWithURL:(NSString *)url
                             progressBlock:(ProgressingHandler)progressBlock
                             completeBlock:(DownLoadCompletionBLock)completeBlock;

/**
 *  下载文件到指定目录
 */
- (NSURLSessionTask *)downloadFilesWithURL:(NSString *)url
                                toLocation:(NSString *)filePath
                             progressBlock:(ProgressingHandler)progressBlock
                             completeBlock:(DownLoadCompletionBLock)completeBlock;

/**
 *  取消下载
 */
//- (void)cancelRequest;

@end
