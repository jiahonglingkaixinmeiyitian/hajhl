//
//  PSH5WebViewController.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "PSH5WebViewController.h"
#import <WebKit/WebKit.h>

@interface PSH5WebViewController ()<WKUIDelegate, WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *topTitle;

@end

@implementation PSH5WebViewController

- (void)dealloc {
    [_webView setNavigationDelegate:nil];
    [_webView setUIDelegate:nil];
}

- (instancetype)initWithURL:(NSString *)urlString title:(NSString *)title {
    if (self = [super init]) {
        self.url = [NSURL URLWithString:urlString];
        self.topTitle = title;
    }
    return self;
}

- (instancetype)initWithFileURLPath:(NSString *)urlPath title:(NSString *)title {
    if (self = [super init]) {
        self.url = [NSURL fileURLWithPath:urlPath];
        self.topTitle = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.topTitle;
    [self setUpView];
    
}

- (void)setUpView {
    
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

#pragma mark - WKUIDelegate, WKNavigationDelegate

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {

}


//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {

    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Property Getters

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] init];
        _webView.backgroundColor = [UIColor mainBackgroundColor];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

@end
