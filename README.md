WebViewJsBridge
===============

A bridge used for Objective-C and JavaScript, which implements the same mechanism as in Android.


## Update
* Add method:
```objective-c
	- (void)yoyo_addJavascriptInterface:(id)object forName:(NSString *)name;
```

## Usage
```objective-c
    NSString* htmlPath = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
    NSString* appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

    JsObject* jsObject = [[JsObject alloc] init];
    [_webview yoyo_addJavascriptInterface:jsObject forName:@"GameHelper"];
    [_webview loadHTMLString:appHtml baseURL:nil];
```

