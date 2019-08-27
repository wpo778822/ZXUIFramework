//
//  ZLCWebView.h
//  测试
//
//  Created by shining3d on 16/6/17.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
@class ZXWebView;
@protocol ZXWebViewDelegate <NSObject>
#pragma mark - ********************  代理方法
- (void)zxartWebView:(ZXWebView *)webview didFinishLoadingURL:(NSURL *)URL;
- (void)zxartWebViewDidStartLoad:(ZXWebView *)webview;
- (void)zxartWebViewDidFailLoad:(ZXWebView *)webview;
- (void)zxartWebViewCallJS:(ZXWebView *)webview callMessage:(WKScriptMessage *)message;
- (void)zxartWebViewCreateNewWebside:(ZXWebView *)webview request:(NSURLRequest *)request;
@end
@interface ZXWebView : UIView<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, weak) id <ZXWebViewDelegate> delegate;

#pragma mark - ********************  外部对象
@property (nonatomic, weak) UIProgressView *progressView;
@property (nonatomic, weak) WKWebView *wkWebView;
@property (nonatomic, assign , getter=isProgressViewUp) BOOL isUpProgressView;
#pragma mark - ********************  外部方法
- (void)loadRequest:(NSURLRequest *)request;
- (void)loadURL:(NSURL *)URL;
- (void)loadURLString:(NSString *)URLString;

@end
