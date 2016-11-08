//
//  UIWebView+JsBridge.h
//  GameApp
//
//  Created by ervinchen on 15/5/26.
//  Copyright (c) 2015年 ccnyou. All rights reserved.
//

#import <UIKit/UIKit.h>


@class WebViewJsBridge;


@interface UIWebView (bridge)

@property (nonatomic, strong) WebViewJsBridge* bridge;

- (void)yoyo_addJavascriptInterface:(id)object forName:(NSString *)name;
- (void)yoyo_addJavascriptInterface:(id)object forName:(NSString *)name protocolScheme:(NSString *)protocolScheme readyEventName:(NSString *)readyEventName;
- (void)yoyo_executeCallback:(NSArray *)args;
- (void)yoyo_excuteJSWithObj:(NSString *)obj function:(NSString *)function args:(NSArray *)args;

@end
