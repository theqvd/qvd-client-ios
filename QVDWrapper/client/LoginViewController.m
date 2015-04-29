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
#import "A0SimpleKeychain.h"


@interface LoginViewController ()

@end

@implementation LoginViewController



-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237./255. green:129./255. blue:9./255. alpha:1.];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"The QVD";
    self.versionLabel.text = [NSString stringWithFormat:@"Versión: %@ (Build: %@)",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

- (IBAction)doLogin:(id)sender {
    NSString *auxLogin = [self.txtLogin.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *auxPassword = [self.txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *auxHost = [self.txtHost.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    ConnectionVO *auxConnection = nil;
    if(![auxHost isEqualToString:@""] || ![auxLogin isEqualToString:@""] || ![auxPassword isEqualToString:@""]){
        auxConnection = [ConnectionVO initWithUser:auxLogin andPassword:auxPassword andHost:auxHost];
    }
    VmListViewController *vmList = [[VmListViewController alloc] initWithConnection:auxConnection saveCredentials:self.switchRemember.isOn];
    [self.navigationController pushViewController:vmList animated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self retreiveUserInfo];
}

-(void)retreiveUserInfo{
    
    if([[A0SimpleKeychain keychain] hasValueForKey:@"qvd-user"]){
        
        [self.txtLogin setText:[[A0SimpleKeychain keychain] stringForKey:@"qvd-user"]];
        [self.txtPassword setText:[[A0SimpleKeychain keychain] stringForKey:@"qvd-pwd"]];
        [self.txtHost setText:[[A0SimpleKeychain keychain] stringForKey:@"qvd-host"]];
        [self.switchRemember setOn:YES];
    } else {
        [self.switchRemember setOn:NO];
        [self.txtHost setText:@""];
        [self.txtPassword setText:@""];
        [self.txtHost setText:@""];
        
    }
    


}


@end
