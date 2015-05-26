//
//  JsObject.h
//  Demo
//
//  Created by ervinchen on 15/5/26.
//  Copyright (c) 2015年 tsinghua. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JsObject : NSObject

// 有成员变量时候生成非法 js 函数 ".cxx_destruct"
@property (nonatomic, strong) NSString* member;

- (void)test1:(NSArray *)args;
- (void)test2;

@end
