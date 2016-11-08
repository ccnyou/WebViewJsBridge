//
//  WebViewJsBridge.m
//  VoxStudent
//
//  Created by zhaoxy on 14-3-8.
//  Copyright (c) 2014年 17zuoye. All rights reserved.
//

#import "WebViewJsBridge.h"
#import <objc/runtime.h>

@interface NSArray (Yoyo)
// 用 elementBlock 拷贝元素，拷贝之前都会经过 elementBlock 处理，返回处理之后的元素
- (NSArray *)yoyo_copyElements:(id (^)(id element))elementBlock;
@end

@implementation NSArray (Yoyo)

- (NSArray *)yoyo_copyElements:(id (^)(id element))elementBlock {
    NSMutableArray* result = [[NSMutableArray alloc] init];
    for (id element in self) {
        id newElement = elementBlock(element);
        if (newElement) {
            [result addObject:newElement];
        }
    }
    
    return result;
}

@end


@interface WebViewJsBridge ()
@property (nonatomic,   weak) id         webViewDelegate;
@property (nonatomic,   weak) NSBundle*  resourceBundle;
@property (nonatomic, strong) NSString*  bridgeName;
@property (nonatomic, strong) id         bridgeObject;
@end


@implementation WebViewJsBridge

+ (instancetype)bridgeForWebView:(UIWebView *)webView
                    bridgeObject:(id)bridgeObject
                      bridgeName:(NSString *)bridgeName
                 webViewDelegate:(NSObject<UIWebViewDelegate>*)webViewDelegate {
    return [self bridgeForWebView:webView
                     bridgeObject:bridgeObject
                       bridgeName:bridgeName
                  webViewDelegate:webViewDelegate
                   resourceBundle:nil];
}

+ (instancetype)bridgeForWebView:(UIWebView *)webView
                    bridgeObject:(id)bridgeObject
                      bridgeName:(NSString *)bridgeName
                 webViewDelegate:(NSObject<UIWebViewDelegate> *)webViewDelegate
                  resourceBundle:(NSBundle *)bundle {
    WebViewJsBridge* bridge = [[WebViewJsBridge alloc] init];
    [bridge _platformSpecificSetup:webView
                      bridgeObject:bridgeObject
                        bridgeName:bridgeName
                   webViewDelegate:webViewDelegate
                    resourceBundle:bundle];
    return bridge;
}

- (NSString *)protocolScheme {
    if (!_protocolScheme) {
        _protocolScheme = @"jscall";
    }
    
    return _protocolScheme;
}

- (NSString *)readyEventName {
    if (!_readyEventName) {
        _readyEventName = @"JsBridgeReady";
    }
    
    return _readyEventName;
}


#pragma mark - init & dealloc

- (void)_platformSpecificSetup:(UIWebView*)webView
                  bridgeObject:(id)bridgeObject
                    bridgeName:(NSString *)bridgeName
               webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate
                resourceBundle:(NSBundle*)bundle{
    _webView = webView;
    _bridgeObject = bridgeObject;
    _bridgeName = bridgeName;
    _webViewDelegate = webViewDelegate;
    _webView.delegate = self;
    _resourceBundle = bundle;
}

- (BOOL)_isJavascriptInserted {
    NSString* javascript = [NSString stringWithFormat:@"typeof %@ == 'object'", self.bridgeName];
    NSString* jsResult = [self.webView stringByEvaluatingJavaScriptFromString:javascript];
    if ([jsResult isEqualToString:@"true"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)_isMethodNameValid:(NSString *)methodName {
    if ([methodName characterAtIndex:0] == '.') {
        return NO;
    }
    
    // add any filter here if needed
    
    return YES;
}

- (void)_insertJavascript {
    unsigned int methodCount = 0;
    //get class method dynamically
    Method *methods = class_copyMethodList([self.bridgeObject class], &methodCount);
    NSMutableString *methodList = [NSMutableString string];
    for (int i = 0; i < methodCount; i++) {
        const char* pMethodName = sel_getName(method_getName(methods[i]));
        NSString *methodName = [NSString stringWithCString:pMethodName encoding:NSUTF8StringEncoding];
        if (![self _isMethodNameValid:methodName]) {
            continue;
        }
        
        [methodList appendString:@"\""];
        [methodList appendString:[methodName stringByReplacingOccurrencesOfString:@":" withString:@""]];
        [methodList appendString:@"\","];
    }
    
    if (methodList.length > 0) {
        [methodList deleteCharactersInRange:NSMakeRange(methodList.length - 1, 1)];
    }
    
    NSBundle *bundle = _resourceBundle ? _resourceBundle : [NSBundle mainBundle];
    NSString *filePath = [bundle pathForResource:@"WebViewJsBridge" ofType:@"js"];
    NSString *jsFileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSString* javascript = [NSString stringWithFormat:jsFileContent, self.bridgeName, self.protocolScheme, self.readyEventName, methodList];
    __strong UIWebView* webView = self.webView;
    if (webView) {
        [webView stringByEvaluatingJavaScriptFromString:javascript];
    }
    
    // You must free the array with free().
    if (methods) {
        free(methods);
    }
}

- (void)_callBridgeMethodWithUrl:(NSURL *)url {
    NSArray *components = [[url absoluteString] componentsSeparatedByString:@":"];
    
    NSString *methodName = (NSString *)[components objectAtIndex:1];
    NSString *argsAsString = [(NSString*)[components objectAtIndex:2]
                              stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *argsData = [argsAsString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *argsDic = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:argsData options:kNilOptions error:NULL];
    //convert js array to objc array
    NSMutableArray *args = [NSMutableArray array];
    for (int i = 0; i < [argsDic count]; i++) {
        [args addObject:[argsDic objectForKey:[NSString stringWithFormat:@"%d", i]]];
    }
    
    //ignore warning
    NSString* selectorName = [args count] > 0 ? [methodName stringByAppendingString:@":"] : methodName;
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL selector = NSSelectorFromString(selectorName);
    if ([self.bridgeObject respondsToSelector:selector]) {
        [self.bridgeObject performSelector:selector withObject:args];
    }
}

#pragma mark - UIWebView Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView != _webView) { return; }

    if (![self _isJavascriptInserted]) {
        [self _insertJavascript];
    }

    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [strongDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [strongDelegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (webView != _webView) {
        return YES;
    }
    
    NSURL *url = [request URL];
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    
    NSString *requestString = [[request URL] absoluteString];
    if ([requestString hasPrefix:self.protocolScheme]) {
        [self _callBridgeMethodWithUrl:url];
        return NO;
    } else if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        return [strongDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    } else {
        return YES;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (webView != _webView) { return; }
    
    __strong typeof(_webViewDelegate) strongDelegate = _webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [strongDelegate webViewDidStartLoad:webView];
    }
}

#pragma mark - call js

//执行js方法
- (void)excuteJSWithObj:(NSString *)obj function:(NSString *)function {
    NSString *js = function;
    if (obj) {
        js = [NSString stringWithFormat:@"%@.%@", obj, function];
    }
    
    //js = [NSString stringWithFormat:@";function(){ window[\"alert\"] = function(msg) { GameHelper.log(msg) }; %@; })();", js];
    NSLog(@"excuteJS:%@", js);
    __strong UIWebView* webView = self.webView;
    if (webView) {
        [webView stringByEvaluatingJavaScriptFromString:js];
    }
}

- (void)excuteJSWithObj:(NSString *)obj function:(NSString *)function args:(NSArray *)args {
    if (!args) {
        return;
    }
    
    args = [args yoyo_copyElements:^id(id element) {
        NSError* error = nil;
        NSData* data = [NSJSONSerialization dataWithJSONObject:@[element] options:0 error:&error];
        NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString* result = [json substringWithRange:NSMakeRange(1, json.length - 2)];
        return result;
    }];
    
    NSString* arguments = [args componentsJoinedByString:@","];
    function = [NSString stringWithFormat:@"%@(%@)", function, arguments];
    [self excuteJSWithObj:obj function:function];
}

- (void)excuteCallback:(NSArray *)args {
    [self excuteJSWithObj:self.bridgeName function:@"callback" args:args];
}

@end
