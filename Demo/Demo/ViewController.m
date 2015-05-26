//
//  ViewController.m
//  WebViewJsBridge
//
//  Created by zhaoxy on 14-4-2.
//  Copyright (c) 2014年 tsinghua. All rights reserved.
//

#import "ViewController.h"
#import "UIWebView+JsBridge.h"
#import "JsObject.h"


@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webview;

@end


@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
    
    JsObject* jsObject = [[JsObject alloc] init];
    [_webview yoyo_addJavascriptInterface:jsObject forName:@"GameHelper"];
    [_webview loadHTMLString:appHtml baseURL:nil];
}

//#pragma mark - WebView Delegate
//
//- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSLog(@"%s %d webViewDidFinishLoad", __FUNCTION__, __LINE__);
//}

@end
