//
//  NSURLProtocol+WKWebVIew.h
//  WebViewBridge
//
//  Created by 李永杰 on 2018/9/4.
//  Copyright © 2018年 muheda. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSURLProtocol (WKWebVIew)

+ (void)mdRegisterScheme:(NSString*)scheme;

+ (void)mdUnregisterScheme:(NSString*)scheme;


@end
