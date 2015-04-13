//
//  VncViewController.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 6/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "VncViewController.h"
#import "QVDClientWrapper.h"
#import "KVNProgressConfiguration.h"
#import "KVNProgress.h"

@interface VncViewController ()
    @property (strong,nonatomic) NSURLRequest* serviceRequest;
    @property (strong,nonatomic) QVDVmVO *selectedVm;
    @property (assign,nonatomic) BOOL hasToConnect;
@end

@implementation VncViewController


-(id)initWithVm:(QVDVmVO *)anVm{
    self = [super initWithNibName:nil bundle:nil];
    if(self){
        _selectedVm = anVm;
        _hasToConnect = YES;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237./255. green:129./255. blue:9./255. alpha:1.];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"The QVD";
    NSLog(@"testing load resource: %@",[[NSBundle mainBundle] pathForResource:@"qvd_vnc" ofType:@"html"]);
    if(self.hasToConnect){
        if(self.selectedVm){
            [self showLoading];
            [[QVDClientWrapper sharedManager] setStatusDelegate:self];
            [[QVDClientWrapper sharedManager] connectToVm:[self.selectedVm id]];
            [self loadUrl];
        }
    }
  
}

-(void)loadUrl{
    NSString *novnc_path = [[NSBundle mainBundle] pathForResource:@"qvd_vnc" ofType:@"html" inDirectory:@"html_resources"];
    NSString *loglevel = @"debug";
    NSString *novnc_url = [ NSString stringWithFormat:@"file://%@?autoconnect=true&logging=%@&host=%s&port=%d&encrypt=false&true_color=1&password=%s", novnc_path, loglevel, "127.0.0.1", 5800, "ben1to" ];
    NSLog(@"novnc_url %@", novnc_url);
    NSURL *url = [NSURL URLWithString:novnc_url];
    // TODO use
    self.serviceRequest = [NSURLRequest requestWithURL:url];
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
    [KVNProgress dismiss];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"==================");
    NSLog(@"%@",error);
    NSLog(@"==================");
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[QVDClientWrapper sharedManager] setStatusDelegate:nil];
    [[QVDClientWrapper sharedManager] endConnection];
}

-(void)showLoading{
    KVNProgressConfiguration *config = [KVNProgressConfiguration defaultConfiguration];
    config.lineWidth = 4.;
    config.backgroundTintColor = [UIColor colorWithRed:237./255. green:129./255. blue:9./255. alpha:1.];
    config.statusColor = [UIColor whiteColor];
    config.successColor = [UIColor whiteColor];
    config.errorColor = [UIColor whiteColor];
    config.circleStrokeForegroundColor = [UIColor whiteColor];
    config.fullScreen = YES;
    [KVNProgress setConfiguration:config];
    [KVNProgress showWithStatus:@"Conectando...."];
}

- (void) qvdProgressMessage:(NSString *) aMessage{
    NSLog(@"Tengo el progresooooooooo: %@",aMessage);
    [KVNProgress updateStatus:aMessage];
    [self loadUrl];
}

- (void) vmListRetreived:(NSArray *) aVmList{
    
}

@end
