//
//  VncViewController.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 6/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "VncViewController.h"
#import "QVDClientWrapper.h"

@interface VncViewController ()
    @property (strong,nonatomic) NSURLRequest* serviceRequest;
@end

@implementation VncViewController


-(void)viewDidLoad{
    [super viewDidLoad];
    NSLog(@"testing load resource: %@",[[NSBundle mainBundle] pathForResource:@"qvd_vnc" ofType:@"html"]);
    //qvd_vnc
    
    
    NSString *novnc_path = [[NSBundle mainBundle] pathForResource:@"qvd_vnc" ofType:@"html" inDirectory:@"html_resources"];
    NSString *loglevel = @"debug";
    NSString *novnc_url = [ NSString stringWithFormat:@"file://%@?autoconnect=true&logging=%@&host=%s&port=%d&encrypt=false&true_color=1&password=%s", novnc_path, loglevel, "127.0.0.1", 5800, "ben1to" ];
    NSLog(@"novnc_url %@", novnc_url);
    NSURL *url = [NSURL URLWithString:novnc_url];
    // TODO use
    self.serviceRequest = [NSURLRequest requestWithURL:url];
    
   /* [self.vncWebView loadRequest:req];*/
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.serviceRequest){
        [self.navegador loadRequest:self.serviceRequest];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webViewDidStartLoad");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"webViewDidFinishLoad");
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"==================");
    NSLog(@"%@",error);
    NSLog(@"==================");
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[QVDClientWrapper sharedManager] endConnection];
}

@end
