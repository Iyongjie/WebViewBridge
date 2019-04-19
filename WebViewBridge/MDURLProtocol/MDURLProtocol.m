//
//  MDURLProtocol.m
//  WebViewBridge
//
//  Created by 李永杰 on 2018/9/4.
//  Copyright © 2018年 muheda. All rights reserved.
//


#import "MDURLProtocol.h"
#import <UIKit/UIKit.h>

static NSString* const KHybridNSURLProtocolHKey = @"KHybridNSURLProtocol";
@interface MDURLProtocol ()<NSURLSessionDelegate>
@property (nonnull,strong) NSURLSessionDataTask *task;

@end

@implementation MDURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    //YES,可以修改响应体.跳转到startLoading
    NSLog(@"拦截到所有的请求%@",request.URL.absoluteString);
    if ([request.URL.absoluteString containsString:@"app.9c97dd8610461dd4787152b9644d8192.css"]) {
        return YES;
    }
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

+ (BOOL)requestIsCacheEquivalent:(NSURLRequest *)a toRequest:(NSURLRequest *)b
{
    return [super requestIsCacheEquivalent:a toRequest:b];
}

- (void)startLoading
{
    
    NSMutableURLRequest* request = self.request.mutableCopy;
    [NSURLProtocol setProperty:@YES forKey:KHybridNSURLProtocolHKey inRequest:request];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"app.9c97dd8610461dd4787152b9644d8192" ofType:@"css"];
    NSData* data = [NSData dataWithContentsOfFile:path];
/*
    js      application/x-javascript.css,
    css     text/css
*/
    NSURLResponse* response = [[NSURLResponse alloc] initWithURL:self.request.URL MIMEType:@"text/css" expectedContentLength:data.length textEncodingName:nil];
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocolDidFinishLoading:self];
}
- (void)stopLoading
{
    if (self.task != nil)
    {
        [self.task  cancel];
    }
}
@end
