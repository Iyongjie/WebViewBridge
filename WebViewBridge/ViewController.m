//
//  ViewController.m
//  WebViewBridge
//
//  Created by 李永杰 on 2018/9/4.
//  Copyright © 2018年 muheda. All rights reserved.
//

#import "ViewController.h"
#import <WebViewJavascriptBridge.h>

#import "MDURLProtocol.h"
#import "NSURLProtocol+WKWebVIew.h"

@import WebKit;


@interface ViewController ()<WKUIDelegate,WKNavigationDelegate>
@property (nonatomic,strong)WKWebView *wkWebView;
@property (nonatomic,strong)WebViewJavascriptBridge *bridge;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIImageView *tmpImageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [NSURLProtocol registerClass:[MDURLProtocol class]];
//
//    [NSURLProtocol mdRegisterScheme:@"http"];
//    [NSURLProtocol mdRegisterScheme:@"https"];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height+200);
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.wkWebView];
    
    self.tmpImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.wkWebView.frame.size.height, self.view.frame.size.width, 200)];
    self.tmpImageView.image = [UIImage imageNamed:@"kvc.png"];
    [self.scrollView addSubview:self.tmpImageView];

    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://clienttemporary.muheda.com/mallOrderProject/#/order"]]];
    

    _bridge = [WebViewJavascriptBridge bridgeForWebView:self.wkWebView];
    [_bridge setWebViewDelegate:self];
 
    
    
    /*
     1. 注册OC方法名
     
    */
    
//JS调用OC
    [self.bridge registerHandler:@"nativeFunction" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"%@",data);
        CGFloat height = [data[@"height"] floatValue];
        CGRect webViewFrame = self.wkWebView.frame;

        self.wkWebView.frame = CGRectMake(0, 0, webViewFrame.size.width, height);

        CGRect imageViewFrame = self.tmpImageView.frame;
        self.tmpImageView.frame = CGRectMake(0, height, imageViewFrame.size.width, 200);

        self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height + 200);
        
        if (responseCallback) {
            // 反馈给JS
            responseCallback(@{@"uuid": data[@"uuid"],@"token":data[@"token"],@"height":data[@"height"]});
        }
       
    }];
//OC调用JS。回调
    [self.bridge callHandler:@"jsFunction" data:@{@"method":@"111"} responseCallback:^(id responseData) {
        NSLog(@"%@",responseData);
    }];
}

 

-(WKWebView *)wkWebView{
    if (!_wkWebView) {

        
        _wkWebView = [[WKWebView alloc]initWithFrame:self.view.frame];
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        _wkWebView.scrollView.scrollEnabled = NO;
        _wkWebView.scrollView.showsVerticalScrollIndicator = NO;
    }
    return _wkWebView;
}


- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString *URL = navigationAction.request.URL.absoluteString;
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    NSLog(@"加载完成");
    
}
#pragma mark -- WKUIDelegate
// 显示一个按钮。点击后调用completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 显示两个按钮，通过completionHandler回调判断用户点击的确定还是取消按钮
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 显示一个带有输入框和一个确定按钮的，通过completionHandler回调用户输入的内容
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
