//
//  ZXartNewDetailPageViewController.m
//  ZXartApp
//
//  Created by Apple on 16/7/15.
//  Copyright © 2016年 Apple. All rights reserved.
//
#import "ZXWebPageViewController.h"
#import "ZXWebView.h"
#import <Masonry.h>
@interface ZXWebPageViewController ()<ZXWebViewDelegate>
@property (nonatomic, strong) ZXWebView *webView;
@property (copy   , nonatomic) NSString *URLString;
@end

@implementation ZXWebPageViewController

- (void)dealloc{
    [_webView loadURLString:@"about:blank"];
}

- (instancetype)initWithURLString:(NSString *)URLString{
    self = [super init];
    if (self) {
        _URLString = URLString;
    }
    return self;
}

#pragma mark - ********************  initMethod

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initWebView];
    [self.webView loadURLString:_URLString];
}

- (void)initWebView{
    ZXWebView *webView = [[ZXWebView alloc]init];
    if (@available(iOS 11.0, *)) {
        webView.wkWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:webView];
    WeakSelf(weakSelf)
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(NAVBAR_HEIGHT);
        make.leading.equalTo(weakSelf.view);
        make.trailing.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view);
    }];
    webView.delegate = self;
    self.webView = webView;
}



#pragma mark - ********************  ZXartWebViewDelegate

- (void)zxartWebViewDidFailLoad:(ZXWebView *)webview {
    
}

- (void)zxartWebViewDidStartLoad:(ZXWebView *)webview{
    
}

- (void)zxartWebView:(ZXWebView *)webview didFinishLoadingURL:(NSURL *)URL{
    
}

- (void)zxartWebViewCallJS:(ZXWebView *)webview callMessage:(WKScriptMessage *)message{
    
}
- (void)zxartWebViewCreateNewWebside:(ZXWebView *)webview request:(NSURLRequest *)request{
    
}
@end
