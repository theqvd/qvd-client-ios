//
//  VncViewController.m
//  QVDWrapper
//
//    Qvd client for IOS
//    Copyright (C) 2015  theqvd.com trade mark of Qindel Formacion y Servicios SL
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU Affero General Public License as
//    published by the Free Software Foundation, either version 3 of the
//    License, or (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU Affero General Public License for more details.
//
//    You should have received a copy of the GNU Affero General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
//  Created by Oscar Costoya Vidal on 6/4/15.
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self = [self initWithNibName:@"VncViewController_iPhone" bundle:nil];
    } else {
        self = [self initWithNibName:@"VncViewController_iPad" bundle:nil];
    }
    
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
    self.title = NSLocalizedString(@"common.titleGeneric",@"The QVD");
    if(self.hasToConnect){
        if(self.selectedVm){
            [self showLoading];
            [[QVDClientWrapper sharedManager] setStatusDelegate:self];
            int result = [[QVDClientWrapper sharedManager] connectToVm:[self.selectedVm id]];
            if(result >= 0){
                [self loadUrl];
            }else {
                NSString *anErrorMessage = [NSString stringWithFormat:@"Error conectando a la vm: %@",[[QVDClientWrapper sharedManager] getLastError]];
                [KVNProgress showErrorWithStatus:anErrorMessage];
            }

        }
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        UIViewController *c = [[UIViewController alloc]init];
        [self presentViewController:c animated:NO completion:nil];
        [c dismissViewControllerAnimated:YES completion:nil];
    }

}

-(void)loadUrl{
    NSString *novnc_path = [[NSBundle mainBundle] pathForResource:@"qvd_vnc" ofType:@"html" inDirectory:@"html_resources"];
    NSString *loglevel = @"debug";
    NSString *novnc_url = [ NSString stringWithFormat:@"file://%@?autoconnect=true&logging=%@&host=%s&port=%d&encrypt=false&true_color=1&password=%s", novnc_path, loglevel, "127.0.0.1", 5800, "ben1to" ];
    NSLog(@"novnc_url %@", novnc_url);
    NSURL *url = [NSURL URLWithString:novnc_url];
    // The url should probably loaded in a webview delegate
    [NSThread sleepForTimeInterval:.5f];
    self.serviceRequest = [NSURLRequest requestWithURL:url];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    


}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    if(self.serviceRequest){
        [self.navegador loadRequest:self.serviceRequest];
    }
    [UIViewController attemptRotationToDeviceOrientation];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *url = [[request URL] absoluteString ];
    if ([url hasPrefix:@"ios"]) {
        [ self webToNativeCall:url ];
        return NO;
    }
    return YES;
}

- (void) webToNativeCall:(NSString *)url {
    if ([ url hasPrefix:@"ios-log:"]) {
        NSArray *stringArray = [ url componentsSeparatedByString:@":%23IOS%23" ];
        if (stringArray.count == 2) {
            NSLog(@"UIWebView console: %@", [ stringArray objectAtIndex:1]);
        } else {
            NSLog(@"UIWebView console: Error in the String format should be ios-log:#IOS# but is %@", url);
        }

        return;
    }
    NSLog(@"QVDShowVmController: webToNativeCall: Invoking url %@", url);
    if ([ url isEqualToString:@"ios:disconnect"]) {
      NSLog(@"Disconnect invoked");
        [self disconnectFromVM];
      return;
    }

    NSLog(@"QVDShowVmController: webToNativeCall: Unknown url invoked %@", url);
}

-(void)disconnectFromVM{
    //[[QVDClientWrapper sharedManager] setStatusDelegate:nil];
    //[KVNProgress show];
    [[QVDClientWrapper sharedManager] endConnection];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];


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
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    //[[QVDClientWrapper sharedManager] setStatusDelegate:nil];
    //[[QVDClientWrapper sharedManager] endConnection:[_selectedVm id]];
    [UINavigationController attemptRotationToDeviceOrientation];
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
    [KVNProgress showWithStatus:NSLocalizedString(@"messages.connecting",@"Connecting....")];
}

- (void) qvdProgressMessage:(NSString *) aMessage{
    NSLog(@"Progress message: %@",aMessage);
    [KVNProgress updateStatus:aMessage];
    [self loadUrl];
}

- (void) vmListRetrieved:(NSArray *) aVmList{
    //Not required
}

- (void) qvdError:(NSString *)aMessage{
    [KVNProgress showErrorWithStatus:aMessage completion:^{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}


-(void)connectionFinished{
    [KVNProgress showSuccessWithStatus:NSLocalizedString(@"messages.vmDisconnected",@"VM disconnected")];
    [[QVDClientWrapper sharedManager] setStatusDelegate:nil];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[QVDClientWrapper sharedManager] setStatusDelegate:nil];
}



- (BOOL)shouldAutorotate {
    return YES;
}


-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationLandscapeRight;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
        return YES;
        
    } else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        return YES;
        
    } else {
        return NO;
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
