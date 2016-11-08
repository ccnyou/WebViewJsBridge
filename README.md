WebViewJsBridge
===============

A bridge used for Objective-C and JavaScript, which implements the same mechanism as in Android.


## Usage
* Inject Native Object:
```objective-c
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

    JsObject* jsObject = [[JsObject alloc] init];
    [_webview yoyo_addJavascriptInterface:jsObject forName:@"JsNative"];
    [_webview loadHTMLString:appHtml baseURL:nil];
```

