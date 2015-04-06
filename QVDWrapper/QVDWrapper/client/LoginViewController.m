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

@interface LoginViewController ()

@end

@implementation LoginViewController



- (IBAction)doLogin:(id)sender {
    
    [[QVDClientWrapper sharedManager] setStatusDelegate:self];
    [[QVDClientWrapper sharedManager] setCredentialsWitUser:@"appledevprogram@qindel.com" password: @"applepass" host:@"demo.theqvd.com"];
     [[QVDClientWrapper sharedManager] listOfVms];
}



- (void) qvdProgressMessage:(NSString *) aMessage{
    NSLog(@"QVD CLIENT WRAPPER MESSAGE RECEIVED [%@]",aMessage);
}

- (void) vmListRetreived:(NSArray *) aVmList{
    NSLog(@"QVD CLIENT WRAPPER VM LIST RECEIVED [%@]",aVmList);
    QVDVmVO *anVm = [aVmList objectAtIndex:0];
    [[QVDClientWrapper sharedManager] connectToVm:[anVm id]];
    VncViewController *vnc = [[VncViewController alloc] initWithNibName:nil bundle:nil];
    
    [self.navigationController pushViewController:vnc animated:YES];
}


@end
