;(function() {
    var messagingIframe,
        bridge = '%@',
        protocolScheme = '%@',
		bridgeEventName = '%@';
  
    if (window[bridge]) { return; }

	function _createQueueReadyIframe(doc) {
        messagingIframe = doc.createElement('iframe');
		messagingIframe.style.display = 'none';
		doc.documentElement.appendChild(messagingIframe);
	}
	
	function _dispatchBridgeReadyEvent(element) {
		if (element == 'undefined') {
			element = document;
		}
		
		var event = new Event(bridgeEventName);
		element.dispatchEvent(event);
	}
  
	window[bridge] = {};
    window[bridge].getArguments = function(args) {
    	var lastArg = args[args.length - 1];
    	if (typeof(lastArg) == "function") {
    		this.callback = lastArg;
            args.length = args.length - 1;
    	} else {
    		this.callback = function(){};
    	}
  
        var result = JSON.stringify(args);
    	return result;
    };

    var methods = [%@];
    for (var i = 0; i < methods.length; i++){
        var method = methods[i];
        var code = "(window[bridge])[method] = function " + method + "() { messagingIframe.src = protocolScheme + ':' + arguments.callee.name + ':' + encodeURIComponent(window[bridge].getArguments(arguments));}";
        eval(code);
    }
  
    // 创建iframe，必须在创建external之后，否则会出现死循环
    _createQueueReadyIframe(document);
	// 发送 ready 事件
	_dispatchBridgeReadyEvent(document);
})();
