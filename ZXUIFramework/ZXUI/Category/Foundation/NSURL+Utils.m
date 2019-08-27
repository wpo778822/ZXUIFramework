//
//  NSURL+Utils.m
//  ZXartApp
//
//  Created by mac  on 2018/4/16.
//  Copyright © 2018 Apple. All rights reserved.
//

#import "NSURL+Utils.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"  
@implementation NSURL (Utils)

+ (instancetype)URLWithString:(NSString *)URLString {
    if(![URLString isKindOfClass:[NSString class]]) return nil;
    NSString *url = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                          (CFStringRef)URLString,
                                                                                          (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                                                          NULL,
                                                                                          kCFStringEncodingUTF8));
    
    return url ? [[NSURL alloc] initWithString:url] : nil;
}

@end
