//
//  UIWebView+JsBridge.m
//  GameApp
//
//  Created by ervinchen on 15/5/26.
//  Copyright (c) 2015年 ccnyou. All rights reserved.
//

#import "UIWebView+JsBridge.h"
#import "WebViewJsBridge.h"
#import <objc/runtime.h>

@implementation UIWebView (bridge)

- (void)yoyo_addJavascriptInterface:(id)object forName:(NSString *)name {
    self.bridge = [WebViewJsBridge bridgeForWebView:self bridgeObject:object bridgeName:name webViewDelegate:self.delegate];
}

- (void)yoyo_addJavascriptInterface:(id)object forName:(NSString *)name protocolScheme:(NSString *)protocolScheme readyEventName:(NSString *)readyEventName {
    [self yoyo_addJavascriptInterface:object forName:name];
    self.bridge.protocolScheme = protocolScheme;
    self.bridge.readyEventName = readyEventName;
}

- (void)setBridge:(WebViewJsBridge *)bridge {
    objc_setAssociatedObject(self, @"bridge", bridge, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WebViewJsBridge *)bridge {
    WebViewJsBridge* result = objc_getAssociatedObject(self, @"bridge");
    return result;
}

@end
