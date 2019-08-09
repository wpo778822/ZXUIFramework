//
//  ZXHUDHelper.m
//  XYLQ
//
//  Created by mac on 2018/8/17.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZXHUDHelper.h"
#import "ZXMacro.h"
#define kRequestTimeOutTime 30
@implementation ZXHUDHelper

+ (void)loading{
    [self loading:nil];
}

+ (void)loading:(NSString *)msg{
    [self loading:msg inView:nil];
}

+ (void)loading:(NSString *)msg inView:(UIView *)view{
    UIView *inView = view ? view : kWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:inView animated:YES];
    GCDMain(^{
        if (!msg){
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.label.text = msg;
        }
        [inView addSubview:hud];
        [hud showAnimated:YES];
        // 超时自动消失
        // [hud hide:YES afterDelay:kRequestTimeOutTime];
    });
}

+ (void)hide{
    [self hideInView:kWindow];
}

+ (void)hideInView:(UIView *)view{
    for (UIView *hud in view.subviews) {
        if ([hud isKindOfClass:[MBProgressHUD class]]) {
            [((MBProgressHUD *)hud) hideAnimated:YES];
        }
    }
}

+ (void)progress:(float)progress{
    [self progress:progress inView:nil];
}

+ (void)progress:(float)progress inView:(UIView *)view{
    UIView *inView = view ? view : kWindow;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:inView animated:YES];
    GCDMain(^{
        hud.mode = MBProgressHUDModeDeterminate;
        hud.progress = progress;
        [inView addSubview:hud];
        [hud showAnimated:YES];
        // 超时自动消失
        // [hud hide:YES afterDelay:kRequestTimeOutTime];
    });
}


+ (void)tipMessage:(NSString *)msg{
    [self tipMessage:msg delay:2];
}

+ (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds{
    [self tipMessage:msg delay:seconds completion:nil];
    
}

+ (void)tipMessage:(NSString *)msg delay:(CGFloat)seconds completion:(void (^)(void))completion{
    if (!msg){
        return;
    }
    GCDMain(^{
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:kWindow];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = msg;
        [hud showAnimated:YES];
        [hud hideAnimated:YES afterDelay:seconds];
        GCDTime(seconds, ^{
            if (completion){
                completion();
            }
        });
    });
}


@end
