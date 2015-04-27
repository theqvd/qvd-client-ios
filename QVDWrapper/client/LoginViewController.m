//
//  LoginViewController.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 6/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "LoginViewController.h"
#import "QVDProxyService.h"
#import "QVDXvncService.h"
#import "QVDVmVO.h"
#include "tcpconnect.h"
#import "QVDClientWrapper.h"
#import "VncViewController.h"
#import "VmListViewController.h"
#import "ConnectionVO.h"
#import "KVNProgress.h"

@interface LoginViewController ()

@end

@implementation LoginViewController



-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237./255. green:129./255. blue:9./255. alpha:1.];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"The QVD";
}

- (IBAction)doLogin:(id)sender {
    NSString *auxLogin = [self.txtLogin.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *auxPassword = [self.txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *auxHost = [self.txtHost.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    ConnectionVO *auxConnection = nil;
    if(![auxHost isEqualToString:@""] || ![auxLogin isEqualToString:@""] || ![auxPassword isEqualToString:@""]){
        auxConnection = [ConnectionVO initWithUser:auxLogin andPassword:auxPassword andHost:auxHost];
    }
    VmListViewController *vmList = [[VmListViewController alloc] initWithConnection:auxConnection];
    [self.navigationController pushViewController:vmList animated:YES];
}

- (void) qvdError:(NSString *)aMessage{
    [KVNProgress showErrorWithStatus:aMessage completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}


@end
