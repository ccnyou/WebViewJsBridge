//
//  WebViewJsBridge.h
//  VoxStudent
//
//  Created by zhaoxy on 14-3-8.
//  Copyright (c) 2014年 17zuoye. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface WebViewJsBridge : NSObject<UIWebViewDelegate>

@property (nonatomic,   weak) UIWebView* webView;


+ (instancetype)bridgeForWebView:(UIWebView *)webView
                    bridgeObject:(id)bridgeObject
                      bridgeName:(NSString *)bridgeName
                 webViewDelegate:(NSObject<UIWebViewDelegate>*)webViewDelegate;

+ (instancetype)bridgeForWebView:(UIWebView *)webView
                    bridgeObject:(id)bridgeObject
                      bridgeName:(NSString *)bridgeName
                 webViewDelegate:(NSObject<UIWebViewDelegate>*)webViewDelegate
                  resourceBundle:(NSBundle*)bundle;

- (void)excuteJSWithObj:(NSString *)obj function:(NSString *)function;

@end
