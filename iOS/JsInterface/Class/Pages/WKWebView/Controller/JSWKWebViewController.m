//
//  JSWKWebViewController.m
//  JsBridge
//
//  Created by 甘文鹏 on 2017/12/20.
//  Copyright © 2017年 ganwenpeng.com. All rights reserved.
//

#import "JSWKWebViewController.h"
#import <WebKit/WebKit.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>
#import "NSDictionary+Json.h"

@interface JSWKWebViewController ()<WKNavigationDelegate>
@property(nonatomic, assign) WKWebViewShowType showType;
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) WebViewJavascriptBridge* bridge;
@end

@implementation JSWKWebViewController
- (instancetype)initWithShowType:(WKWebViewShowType)showType {
    if (self = [super init]) {
        self.showType = showType;
    }
    return self;
}

- (void)loadView {
    self.webView = [[WKWebView alloc] init];
    self.view = self.webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化jsbridge对象
    [self setupJsBridge];
    
    // 加载测试用的HTML页面
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jsbridge-test" ofType:@"html"]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)setupJsBridge {
    if (self.bridge) return;
    
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];
    
    [self.bridge registerHandler:@"getOS" handler:^(id data, WVJBResponseCallback responseCallback) {
        // 这里Response的回调可以传id类型数据，但是为了保持Android、iOS的统一，全部使用json字符串作为返回数据
        NSDictionary *response = @{@"error": @(0), @"message": @"", @"data": @{@"os": @"ios"}};
        responseCallback([response jsonString]);
    }];
    
    [self.bridge registerHandler:@"login" handler:^(id data, WVJBResponseCallback responseCallback) {
        if (data == nil || ![data isKindOfClass:[NSDictionary class]]) {
            NSDictionary *response = @{@"error": @(-1), @"message": @"调用参数有误"};
            responseCallback([response jsonString]);
            return;
        }
        
        NSString *account = data[@"account"];
        NSString *passwd = data[@"password"];
        NSDictionary *response = @{@"error": @(0), @"message": @"登录成功", @"data" : [NSString stringWithFormat:@"执行登录操作，账号为：%@、密码为：@%@", account, passwd]};
        responseCallback([response jsonString]);
    }];
}
@end