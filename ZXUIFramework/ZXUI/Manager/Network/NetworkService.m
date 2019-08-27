//
//  nNetworkService.m
//  ZXartApp
//
//  Created by mac  on 27/01/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "NetworkService.h"
#import "AFNetworking.h"
@interface NetworkService () <NSURLSessionDownloadDelegate>


#pragma mark DownLoad
@property (nonatomic,   copy) NSString                 *downloadPath;

@property (nonatomic, strong) NSURLSession             *session;

@property (nonatomic, strong) NSURLSessionDownloadTask *sessionDownloadTask;

@property (nonatomic, strong) NetworkRequest           *request;

@property (nonatomic,   copy) ProgressingHandler       progressHandler;

@property (nonatomic,   copy) SuccessHandler           responseSuccessHandler;

@property (nonatomic,   copy) FailHandler              responseFailHandler;

@property (nonatomic,   copy) DownLoadCompletionBLock  completeBlock;



@end

@implementation NetworkService

+ (instancetype)sharedManager {
    static NetworkService *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeout = 25;
    }
    return self;
}

#pragma mark - Public Method
- (NSUInteger)sendRequest:(NetworkRequest *)request
                 progress:(ProgressingHandler)progressBlock
                  success:(SuccessHandler)responseSuccessBlock
                  failure:(FailHandler)responseFailBlock {
    
    switch (request.requestType) {
        case ZXRequestTypeNormal: {
            return [self dataTaskWithRequest:request
                                    progress:progressBlock
                                     success:responseSuccessBlock
                                     failure:responseFailBlock].taskIdentifier;
            break;
        }
        case ZXRequestTypeUpload: {
            return [self uploadWithRequest:request
                                  progress:progressBlock
                                   success:responseSuccessBlock
                                   failure:responseFailBlock].taskIdentifier;
            break;
        }
        case ZXRequestTypeDownload: {
            return  [self downWithRequest:request
                                 progress:progressBlock
                                  success:responseSuccessBlock
                                  failure:responseFailBlock].taskIdentifier;
            break;
        }
        default:
            return  -1;
            break;
    }
}

- (void)cancelDownload {
    [_sessionDownloadTask suspend];
    [_sessionDownloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
    _sessionDownloadTask = nil;
}

#pragma mark - Private Method
#pragma mark Data Task
- (NSURLSessionTask *)dataTaskWithRequest:(NetworkRequest *)request
                                 progress:(ProgressingHandler)progressBlock
                                  success:(SuccessHandler)responseSuccessBlock
                                  failure:(FailHandler)responseFailBlock {
    AFHTTPSessionManager *manager = [self createsessionManager:request];
    switch (request.httpType) {
        case HTTPTypeGET: {
            return [self GETWithSessionManager:manager
                                           api:request.baseAPI
                                        params:request.parameters
                                 progressBlock:progressBlock
                                  successBlock:responseSuccessBlock
                                  failureBlock:responseFailBlock];
            break;
        }
        case HTTPTypePOST: {
            return [self POSTWithSessionManager:manager
                                            api:request.baseAPI
                                         params:request.parameters
                                  progressBlock:progressBlock
                                   successBlock:responseSuccessBlock
                                   failureBlock:responseFailBlock];
            break;
        }
        case HTTPTypeDELETE: {
            return [self DELETEWithSessionManager:manager
                                              api:request.baseAPI
                                           params:request.parameters
                                    progressBlock:progressBlock
                                     successBlock:responseSuccessBlock
                                     failureBlock:responseFailBlock];
            break;
        }
    }
}

/**
 *  GET
 */
- (NSURLSessionTask *)GETWithSessionManager:(AFHTTPSessionManager *)sessionManager
                                        api:(NSString *)api
                                     params:(id)params
                              progressBlock:(ProgressingHandler)progressBlock
                               successBlock:(SuccessHandler)successBlock
                               failureBlock:(FailHandler)failBlock {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return [sessionManager GET:api parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (successBlock) {
            successBlock(task, resultDictionary ?:responseObject);
        }
        [sessionManager.session finishTasksAndInvalidate];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (failBlock) {
            failBlock(task, error.localizedDescription);
        }
        [sessionManager.session finishTasksAndInvalidate];
    }];
}

/**
 *  POST
 */
- (NSURLSessionTask *)POSTWithSessionManager:(AFHTTPSessionManager *)sessionManager
                                         api:(NSString *)api
                                      params:(id)params
                               progressBlock:(ProgressingHandler)progressBlock
                                successBlock:(SuccessHandler)successBlock
                                failureBlock:(FailHandler)failBlock {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return [sessionManager POST:api parameters:params progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (successBlock) {
            successBlock(task, resultDictionary ?:responseObject);
        }
        [sessionManager.session finishTasksAndInvalidate];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (failBlock) {
            failBlock(task, error.localizedDescription);
        }
        [sessionManager.session finishTasksAndInvalidate];
    }];
}

/**
 *  DELETE
 */
- (NSURLSessionTask *)DELETEWithSessionManager:(AFHTTPSessionManager *)sessionManager
                                           api:(NSString *)api
                                        params:(id)params
                                 progressBlock:(ProgressingHandler)progressBlock
                                  successBlock:(SuccessHandler)successBlock
                                  failureBlock:(FailHandler)failBlock {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    return [sessionManager DELETE:api parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (successBlock) {
            successBlock(task, resultDictionary ?:responseObject);
        }
        [sessionManager.session finishTasksAndInvalidate];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        if (failBlock) {
            failBlock(task, error.localizedDescription);
        }
        [sessionManager.session finishTasksAndInvalidate];
    }];
}

#pragma mark Upload
- (NSURLSessionTask *)uploadWithRequest:(NetworkRequest *)request
                               progress:(ProgressingHandler)progressBlock
                                success:(SuccessHandler)responseSuccessBlock
                                failure:(FailHandler)responseFailBlock {
    
    AFHTTPSessionManager *manager = [self createsessionManager:request];
    return [manager POST:request.baseAPI parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //把图片转换为二进制流
        NSData *imageData = request.uploadData;
        //按照表单格式把二进制文件写入formData表单
        NSString *fullFileName = @"file";
        NSString *dataName;
        NSString *mimeType = @"error";
        NSString *name = @"data";
        
        if (!request.uploadDataName) {
            dataName = [NSString stringWithFormat:@"%0.f",[NSDate new].timeIntervalSince1970];
        }
        else {
            dataName = request.uploadDataName;
        }
        
        if (request.uploadDataType == FileTypeImage) {
            fullFileName = [NSString stringWithFormat:@"%@image.%@",dataName,@"jpg"];
            mimeType = @"image/jpg";
            name = @"image";
        }
        else if (request.uploadDataType == FileTypeVideo) {
            fullFileName = [NSString stringWithFormat:@"%@video.%@",dataName,@"mp4"];
            mimeType = @"video/mp4";
            name = @"video";
        }
        else if (request.uploadDataType == FileTypeAudio) {
            fullFileName = [NSString stringWithFormat:@"%@audio.%@",dataName,@"mp3"];
            mimeType = @"audio/mp3";
            name = @"audio";
        }
        [formData appendPartWithFileData:imageData name:name fileName:fullFileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
//        if (progressBlock) {
//            progressBlock(uploadProgress.currentProgress, uploadProgress.fileTotalCount);
//        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData *data     = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (responseSuccessBlock) {
            responseSuccessBlock(task, resultDictionary);
        }
        [manager.session finishTasksAndInvalidate];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (responseFailBlock) {
            responseFailBlock(task, error.localizedDescription);
        }
        [manager.session finishTasksAndInvalidate];
    }];

}

#pragma mark DownLoad
- (NSURLSessionTask *)downWithRequest:(NetworkRequest *)request
                             progress:(ProgressingHandler)progressHandler
                              success:(SuccessHandler)responseSuccessHandler
                              failure:(FailHandler)responseFailHandler {
    
    _request                = request;
    _progressHandler        = progressHandler;
    _responseSuccessHandler = responseSuccessHandler;
    _responseFailHandler    = responseFailHandler;
    
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                             delegate:self
                                        delegateQueue:[NSOperationQueue mainQueue]];
    
    _sessionDownloadTask = [_session downloadTaskWithURL:[NSURL URLWithString:request.baseAPI]];
    [_sessionDownloadTask resume];
    return _sessionDownloadTask;
}

#pragma mark NSURLSessionDownloadDelegate
//下载完成时调用
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    NSString *filePath = nil;
    if (_request.downloadDestination) {
        filePath = _request.downloadDestination;
    }
    else {
        // 沙盒文件路径
        NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *fullpath = [documentsDirectory stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
        filePath = fullpath;
    }
    
    NSError *error = nil;
    [[NSFileManager defaultManager] copyItemAtURL:location toURL:[NSURL fileURLWithPath:filePath] error:&error];
    
    if (_responseSuccessHandler) {
        _responseSuccessHandler(nil,[NSURL fileURLWithPath:filePath]);
    }
    
    _request = nil;
    _progressHandler = nil;
    _responseSuccessHandler = nil;
    _responseFailHandler = nil;
    _sessionDownloadTask = nil;
    _session             = nil;
    _completeBlock = nil;
}

//跟踪下载进度
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
//    float progress = (float)totalBytesWritten/totalBytesExpectedToWrite;
    if (_progressHandler) {
        _progressHandler(totalBytesWritten,totalBytesExpectedToWrite);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (_responseFailHandler) {
        _responseFailHandler(nil,error);
    }
    _request = nil;
    _progressHandler = nil;
    _responseSuccessHandler = nil;
    _responseFailHandler = nil;
    _completeBlock       = nil;
    _sessionDownloadTask = nil;
    _session             = nil;
}


#pragma mark assetManager
- (AFHTTPSessionManager *)createsessionManager:(NetworkRequest *)request {
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:request.baseAPI]];
//    sessionManager.securityPolicy                            = [self afPolicy];加载证书
    sessionManager.responseSerializer                        = [AFHTTPResponseSerializer serializer];
    sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[
                                                                                      @"application/json",
                                                                                      @"text/html",
                                                                                      @"text/json",
                                                                                      @"text/plain",
                                                                                      @"text/javascript",
                                                                                      @"text/xml",
                                                                                      @"image/*",
                                                                                      @"multipart/form-data"
                                                                                      ]];
    
    switch (request.requestSerializerType) {
        case RequestSerializerJSON: {
            sessionManager.requestSerializer                 = [AFJSONRequestSerializer serializer];
            break;
        }
        case RequestSerializerRAW: {
            sessionManager.requestSerializer                 = [AFHTTPRequestSerializer serializer];
            break;
        }
        default:
            break;
    }
    sessionManager.requestSerializer.timeoutInterval = request.timeout;
    
    NSString *headerValue = nil, *headerField = @"Authorization";
    if (request.headerInfo) {
        headerValue = request.headerInfo[@"Value"];
        headerField = request.headerInfo[@"Field"];
        [sessionManager.requestSerializer setValue:headerValue forHTTPHeaderField:headerField];
    }
    return sessionManager;
}

- (AFSecurityPolicy *)afPolicy {
    NSString *certFilePath = [[NSBundle mainBundle] pathForResource:@"ZXArtcertificate" ofType:@"cer"];
    NSData   *certData     = [NSData dataWithContentsOfFile:certFilePath];
    NSSet    *certSet      = [NSSet setWithObject:certData];
    AFSecurityPolicy *afPolicy        = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate
                                                         withPinnedCertificates:certSet];
    afPolicy.allowInvalidCertificates = YES;
    afPolicy.validatesDomainName      = YES;
    return afPolicy;
}
#pragma mark -----------------------

- (NSURLSessionTask *)sendRequest:(HTTPType)httpType
                              api:(NSString *)api
                           params:(id)params
                    progressBlock:(ProgressingHandler)progressBlock
                     successBlock:(SuccessHandler)responseSuccessBlock
                     failureBlock:(FailHandler)responseFailBlock {
    return [self sendRequest:httpType
                         api:api
                      params:params
              httpheaderInfo:nil
                     timeout:-1
               progressBlock:progressBlock
                successBlock:responseSuccessBlock
                failureBlock:responseFailBlock];
}

/**
 *  发送带Token请求
 */
- (NSURLSessionTask *)sendRequestWithToken:(HTTPType)httpType
                                       api:(NSString *)api
                                    params:(id)params
                             progressBlock:(ProgressingHandler)progressBlock
                              successBlock:(SuccessHandler)responseSuccessBlock
                              failureBlock:(FailHandler)responseFailBlock {
    NSDictionary *httpHeader = nil;
//    if (User_Default_Token && ![User_Default_Token isKindOfClass:[NSNull class]]) {
//        httpHeader = @{
//                       @"Value" : [NSString stringWithFormat:@"bearer %@",User_Default_Token],
//                       @"Field" : @"Authorization",
//                       };
//    }
    return [self sendRequest:httpType
                         api:api
                      params:params
              httpheaderInfo:httpHeader
                     timeout:-1
               progressBlock:progressBlock
                successBlock:responseSuccessBlock
                failureBlock:responseFailBlock];
}

- (NSURLSessionTask *)sendRequest:(HTTPType)httpType
                              api:(NSString *)api
                           params:(id)params
                   httpheaderInfo:(NSDictionary *)httpHeaderInfo
                          timeout:(NSTimeInterval)timeout
                    progressBlock:(ProgressingHandler)progressBlock
                     successBlock:(SuccessHandler)responseSuccessBlock
                     failureBlock:(FailHandler)responseFailBlock {
    
    AFHTTPSessionManager *sessionManager = [self sessionManagerWithTimeout:timeout httpHeaderInfo:httpHeaderInfo baseURL:api];
    switch (httpType) {
        case HTTPTypeGET: {
            return [self GETWithSessionManager:sessionManager
                                           api:api
                                        params:params
                                 progressBlock:progressBlock
                                  successBlock:responseSuccessBlock
                                  failureBlock:responseFailBlock];
            break;
        }
        case HTTPTypePOST: {
            return [self POSTWithSessionManager:sessionManager
                                            api:api
                                         params:params
                                  progressBlock:progressBlock
                                   successBlock:responseSuccessBlock
                                   failureBlock:responseFailBlock];
            break;
        }
        case HTTPTypeDELETE: {
            return [self DELETEWithSessionManager:sessionManager
                                              api:api
                                           params:params
                                    progressBlock:progressBlock
                                     successBlock:responseSuccessBlock
                                     failureBlock:responseFailBlock];
            break;
        }
    }
}
#pragma mark - Upload
- (void)uploadFileType:(FileType)fileType
                   api:(NSString *)api
                  data:(NSData *)fileData
         progressBlock:(ProgressingHandler)progressBlock
          successBlock:(SuccessHandler)responseSuccessBlock
          failureBlock:(FailHandler)responseFailBlock {
    [self uploadFileType:fileType api:api data:fileData fileName:nil httpheaderInfo:nil timeout:-1 progressBlock:progressBlock successBlock:responseSuccessBlock failureBlock:responseFailBlock];
}

- (void)uploadFileType:(FileType)fileType
                   api:(NSString *)api
                  data:(NSData *)fileData
              fileName:(NSString *)fileName
        httpheaderInfo:(NSDictionary *)httpHeaderInfo
               timeout:(NSTimeInterval)timeout
         progressBlock:(ProgressingHandler)progressBlock
          successBlock:(SuccessHandler)responseSuccessBlock
          failureBlock:(FailHandler)responseFailBlock {
 
    AFHTTPSessionManager *manager = [self sessionManagerWithTimeout:timeout httpHeaderInfo:httpHeaderInfo baseURL:api];
    [manager POST:api parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        //把图片转换为二进制流
        NSData *imageData = fileData;
        //按照表单格式把二进制文件写入formData表单
        NSString *fullFileName = @"file";
        NSString *dataName;
        NSString *mimeType = @"error";
        
        if (!fileName) {
            dataName = [NSString stringWithFormat:@"%0.f",[NSDate new].timeIntervalSince1970];
        }
        else {
            dataName = fileName;
        }
        
        if (fileType == FileTypeImage) {
            fullFileName = [NSString stringWithFormat:@"%@.%@",dataName,@"jpg"];
            mimeType = @"image/jpg";
        }
        else if (fileType == FileTypeVideo) {
            fullFileName = [NSString stringWithFormat:@"%@.%@",dataName,@"mp4"];
            mimeType = @"video/mp4";
        }
        
        
        [formData appendPartWithFileData:imageData name:@"file" fileName:fullFileName mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSData *data     = [result dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *resultDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        if (responseSuccessBlock) {
            responseSuccessBlock(task, resultDictionary);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (responseFailBlock) {
            responseFailBlock(task, error.localizedDescription);
        }
    }];
}

#pragma mark - DownLoad
- (NSURLSessionTask *)downloadFilesWithURL:(NSString *)url
                             progressBlock:(ProgressingHandler)progressBlock
                             completeBlock:(DownLoadCompletionBLock)completeBlock {
    return [self downloadFilesWithURL:url toLocation:nil progressBlock:progressBlock completeBlock:completeBlock];
}

- (NSURLSessionTask *)downloadFilesWithURL:(NSString *)url
                                toLocation:(NSString *)filePath
                             progressBlock:(ProgressingHandler)progressBlock
                             completeBlock:(DownLoadCompletionBLock)completeBlock {
    
    _downloadPath = filePath ? filePath : nil;
//    _progressBlock = progressBlock;
    _completeBlock = completeBlock;
    
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                             delegate:self
                                        delegateQueue:[NSOperationQueue mainQueue]];
    
    _sessionDownloadTask = [_session downloadTaskWithURL:[NSURL URLWithString:url]];
    [_sessionDownloadTask resume];
    return _sessionDownloadTask;
}

- (void)cancelDownLoad {
    [_sessionDownloadTask suspend];
    [_sessionDownloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        
    }];
    _sessionDownloadTask = nil;
}


#pragma mark - Private Method


- (AFHTTPSessionManager *)sessionManagerWithTimeout:(NSTimeInterval)timeout httpHeaderInfo:(NSDictionary *)headerInfo baseURL:(NSString *)baseURL {
    
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:baseURL]];
    sessionManager.securityPolicy        = [self afPolicy];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    responseSerializer.acceptableContentTypes =  [NSSet setWithArray:@[
                                                                        @"application/json",
                                                                        @"text/html",
                                                                        @"text/json",
                                                                        @"text/plain",
                                                                        @"text/javascript",
                                                                        @"text/xml",
                                                                        @"image/*",
                                                                        @"multipart/form-data"
                                                                         ]];
    [sessionManager setResponseSerializer:responseSerializer];
    
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    requestSerializer.timeoutInterval = timeout != -1 ? timeout : _timeout;
    NSString *headerValue = nil, *headerField = @"Authorization";
    if (headerInfo && headerInfo[@"Value"] && headerInfo[@"Field"]) {
        headerValue = headerInfo[@"Value"];
        headerField = headerInfo[@"Field"];
    }
    [requestSerializer setValue:headerValue forHTTPHeaderField:headerField];
    [sessionManager setRequestSerializer:requestSerializer];
    return sessionManager;
}


@end
