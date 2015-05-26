//
//  JsObject.m
//  Demo
//
//  Created by ervinchen on 15/5/26.
//  Copyright (c) 2015年 tsinghua. All rights reserved.
//

#import "JsObject.h"

@implementation JsObject

- (instancetype)init {
    self = [super init];
    if (self) {
        self.member = @"ok";
    }
    
    return self;
}

- (void)test1:(NSArray *)args {
    NSLog(@"%s %d args = %@", __FUNCTION__, __LINE__, args);
}

- (void)test2 {
    NSLog(@"%s %d test2, self.member = %@", __FUNCTION__, __LINE__, self.member);
}

- (void)dealloc {
    NSLog(@"%s %d dealloc", __FUNCTION__, __LINE__);
}

@end
