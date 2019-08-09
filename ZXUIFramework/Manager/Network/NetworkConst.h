//
//  XMConst.h
//  XMNetworking
//
//  Created by Zubin Kang on 12/12/2016.
//  Copyright © 2016 XMNetworking. All rights reserved.
//

#ifndef NetworkConst_h
#define NetworkConst_h

@class NetworkRequest;

/**
 Resquest parameter serialization type enum for XMRequest, see `AFURLRequestSerialization.h` for details.
 */
typedef NS_ENUM(NSInteger, RequestSerializerType) {
    RequestSerializerRAW     = 0,
    RequestSerializerJSON    = 1,
    RequestSerializerPlist   = 2,
};

/**
 Response data serialization type enum for XMRequest, see `AFURLResponseSerialization.h` for details.
 */
typedef NS_ENUM(NSInteger, ResponseSerializerType) {
    ResponseSerializerRAW    = 0,
    ResponseSerializerJSON   = 1,
    ResponseSerializerPlist  = 2,
    ResponseSerializerXML    = 3,
};

typedef NS_ENUM(NSInteger, HTTPHeaderType) {
    HTTPHeaderTypeNone,
    HTTPHeaderTypeToken,
    HTTPHeaderTypeAuthen,
    HTTPHeaderTypeOther,
};

typedef NS_ENUM(NSInteger, ZXRequestType) {
    ZXRequestTypeNormal    = 0,
    ZXRequestTypeUpload    = 1,
    ZXRequestTypeDownload  = 2,
};

/**
 *  Http类型
 */
typedef NS_ENUM(NSInteger, HTTPType) {
    HTTPTypeGET,
    HTTPTypePOST,
    HTTPTypeDELETE
};

/**
 *  上传文件请求类型
 */
typedef NS_ENUM(NSInteger, FileType) {
    FileTypeFile,
    FileTypeImage,
    FileTypeVideo,
    FileTypeAudio,
};


/**
 *  请求完成回调
 */
typedef void (^RequestBlock)(NetworkRequest *request);

/**
 *  进度
 */
typedef void (^ProgressingHandler)(int64_t bytesRead, int64_t totalBytes);

/**
 *  请求完成回调
 */
typedef void (^CompleteHandler)(id returnData, id error);

/**
 *  请求成功回调
 */
typedef void (^SuccessHandler)(NSURLSessionDataTask *task, id returnData);

/**
 *  请求失败回调
 */
typedef void (^FailHandler)(NSURLSessionDataTask *task, id error);

/**
 *  下载完成回调
 */
typedef void (^DownLoadCompletionBLock)(NSURL *filePath, NSError *error);

//NS_ASSUME_NONNULL_END

#endif /* NetworkConst_h */
