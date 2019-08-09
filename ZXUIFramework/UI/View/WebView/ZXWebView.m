//
//  ZLCWebView.m
//  测试
//
//  Created by shining3d on 16/6/17.
//  Copyright © 2016年 shining3d. All rights reserved.
//

#import "ZXWebView.h"
#import <Masonry.h>

static void *ZXWebBrowserContext = &ZXWebBrowserContext;

@interface ZXWebView ()<UIGestureRecognizerDelegate,WKScriptMessageHandler>

@property (nonatomic, weak) NSTimer *fakeProgressTimer;

@property (nonatomic, assign) NSInteger i;

@end
@implementation ZXWebView

#pragma mark --Initializers
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        WKWebView *wkWebView = [[WKWebView alloc] init];
        self.wkWebView = wkWebView;
        self.backgroundColor = [UIColor whiteColor];
            [self.wkWebView setFrame:frame];
        wkWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        wkWebView.contentMode = UIViewContentModeRedraw;
        wkWebView.opaque = YES;
        wkWebView.UIDelegate = self;
        wkWebView.navigationDelegate = self;
        wkWebView.allowsBackForwardNavigationGestures = YES;
        [self addSubview:wkWebView];
        UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView = progressView;
        [self addSubview:self.progressView];
        [self.progressView setTrackTintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]];
        [self.progressView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        self.progressView.layer.shadowColor = [UIColor colorWithRed:140.0 green:140.0 blue:140.0 alpha:1].CGColor;
        self.progressView.layer.shadowOffset = CGSizeMake(0, 0.1);
        self.progressView.layer.shadowOpacity = 0.6;
        [self.progressView setTintColor:[UIColor blueColor]];
        self.isUpProgressView = YES;
        if (@available(iOS 9.0, *)) {
            wkWebView.allowsLinkPreview = NO;
            NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
            NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
            [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            }];
        }
        [self closeTouch];
        [self.wkWebView addObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress)) options:0 context:ZXWebBrowserContext];
    }
    return self;
}

- (void)closeTouch{
    //禁止长按弹出 UIMenuController 相关
    //禁止选择 css 配置相关
    NSString *css = @"body{-webkit-user-select:none;-webkit-user-drag:none;}";
    //css 选中样式取消
    NSMutableString * javascript = [NSMutableString string];
//    [javascript appendString:@"var style = document.createElement('style');"];
//    [javascript appendString:@"style.type = 'text/css';"];
    [javascript appendFormat:@"var cssContent = document.createTextNode('%@');", css];//禁止缩放
//    [javascript appendString:@"style.appendChild(cssContent);"];
//    [javascript appendString:@"document.body.appendChild(style);"];
//    [javascript appendString:@"document.documentElement.style.webkitUserSelect='none';"];//禁止选择
    [javascript appendString:@"document.documentElement.style.webkitTouchCallout='none';"];//禁止长按
    //javascript 注入
    WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:javascript
                                                            injectionTime:WKUserScriptInjectionTimeAtDocumentEnd
                                                         forMainFrameOnly:YES];
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    [userContentController addUserScript:noneSelectScript];
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = userContentController;
    //控件加载
    [self.wkWebView.configuration.userContentController addUserScript:noneSelectScript];
}


- (void)setIsUpProgressView:(BOOL)isUpProgressView{
    _isUpProgressView = isUpProgressView;
    [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        isUpProgressView ? make.top.equalTo(self) : make.bottom.equalTo(self);
        make.leading.equalTo((self));
        make.trailing.equalTo((self));
        make.height.equalTo(@2.0);
    }];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - load 方法
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView{
    [webView reload];
}
- (void)loadRequest:(NSURLRequest *)request {
    [self.wkWebView loadRequest:request];
}

- (void)loadURL:(NSURL *)URL {
    [self loadRequest:[NSURLRequest requestWithURL:URL]];
}

- (void)loadURLString:(NSString *)URLString {
    if(![URLString isKindOfClass:[NSString class]]) return;
    URLString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)URLString,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    [self loadURL:[NSURL URLWithString:URLString]];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if (_delegate && [_delegate respondsToSelector:@selector(zxartWebViewCallJS:callMessage:)]) {
        [self.delegate zxartWebViewCallJS:self callMessage:message];
    }
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures{
    if (_delegate && [_delegate respondsToSelector:@selector(zxartWebViewCreateNewWebside:request:)]) {
        [self.delegate zxartWebViewCreateNewWebside:self request:navigationAction.request];
    }else{
        if (!navigationAction.targetFrame.isMainFrame) {
            [webView loadRequest:navigationAction.request];
        }
    }
    return nil;
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    //开始加载
    if (_delegate && [_delegate respondsToSelector:@selector(zxartWebViewDidStartLoad:)]) {
        [self.delegate zxartWebViewDidStartLoad:self];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.delegate && [self.delegate respondsToSelector:@selector(zxartWebView:didFinishLoadingURL:)]) {
        [self.delegate zxartWebView:self didFinishLoadingURL:self.wkWebView.URL];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    NSURL *url = navigationAction.request.URL;
    if(webView != self.wkWebView) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    UIApplication *app = [UIApplication sharedApplication];
    if ([url.scheme isEqualToString:@"tel"]){
        if ([app canOpenURL:url])
        {
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }else if ([url.absoluteString containsString:@"itunes.apple.com"]){
        if ([app canOpenURL:url]){
            [app openURL:url];
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        };
    }else{
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
}


- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    if(!self.wkWebView.isLoading) {
        // 停止滚动条
        [self fakeProgressBarStopLoading];
        //加载失败
        if (self.delegate && [self.delegate respondsToSelector:@selector(zxartWebViewDidFailLoad:)]) {
            [self.delegate zxartWebViewDidFailLoad:self];
        }
    }
}


#pragma mark - 进度条KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))] && object == self.wkWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = self.wkWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:self.wkWebView.estimatedProgress animated:animated];
        if(self.wkWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.progressView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [self.progressView setProgress:0.0f animated:NO];
            }];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - 进度条方法

- (void)fakeProgressViewStartLoading {
    [self.progressView setProgress:0.0f animated:NO];
    [self.progressView setAlpha:1.0f];
    
    if(!self.fakeProgressTimer) {
        NSTimer *fakeProgressTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f/60.0f target:self selector:@selector(fakeProgressTimerDidFire:) userInfo:nil repeats:YES];
        self.fakeProgressTimer = fakeProgressTimer;
    }
}

- (void)fakeProgressBarStopLoading {
    if(self.fakeProgressTimer) {
        [self.fakeProgressTimer invalidate];
    }
    if(self.progressView) {
        [self.progressView setProgress:1.0f animated:YES];
        [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.progressView setAlpha:0.0f];
        } completion:^(BOOL finished) {
            [self.progressView setProgress:0.0f animated:NO];
        }];
    }
}

- (void)fakeProgressTimerDidFire:(id)sender {
    CGFloat increment = 0.005 / (self.progressView.progress + 0.2);
    if([self.wkWebView isLoading]) {
        CGFloat progress = (self.progressView.progress < 0.75f) ? self.progressView.progress + increment : self.progressView.progress + 0.0005;
        if(self.progressView.progress < 0.95) {
            [self.progressView setProgress:progress animated:YES];
        }
    }
}

#pragma mark - Dealloc

- (void)dealloc {
    [self.wkWebView setNavigationDelegate:nil];
    [self.wkWebView setUIDelegate:nil];
    [self.wkWebView removeObserver:self forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

@end
