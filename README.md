WebViewJsBridge
===============

A bridge used for Objective-C and JavaScript, which implements the same mechanism as in Android.


## Usage
* Inject Native OC Object:
```objective-c
    JsObject* jsObject = [[JsObject alloc] init];
    [_webview yoyo_addJavascriptInterface:jsObject forName:@"JsNative"];
    [_webview loadHTMLString:appHtml baseURL:nil];
```

* Js callback
```objective-c
	// js: JsNative.testCallback1("arg1", "call_back_name");
	[webview yoyo_excuteJSWithObj:@"window" function:@"call_back_name" args:@[result]];

	// js: JsNative.testCallback1("arg1", function(arg) {});
	[webview yoyo_executeCallback:@[result]];
```

