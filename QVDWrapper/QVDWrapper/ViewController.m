//
//  ViewController.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 25/2/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "ViewController.h"
#import "QVDProxyService.h"
#import "QVDXvncService.h"
#import "QVDVmVO.h"
#include "tcpconnect.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {

}


-(void)viewDidAppear:(BOOL)animated{

    [self testServices];
    //[self testWrapper];

}

-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"Desaparezzzzzzco......");
}


#pragma mark - Services

-(void)testServices{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startXVNC)
                                                 name:@"QVDProxyServiceStarted"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(testWrapper)
                                                 name:@"QVDXVNCServiceStarted"
                                               object:nil];
    QVDProxyService *proxyService =  [[QVDProxyService alloc] init];
    [proxyService startService];
}

-(void)startXVNC{
    NSLog(@"STAAAAAAAART XVNC");
    QVDXvncService *xvncService =  [[QVDXvncService alloc] init];
    [xvncService startService];
}


#pragma mark - Wrapper

-(void)testWrapper{
    [[QVDClientWrapper sharedManager] setCredentialsWitUser:@"appledevprogram@qindel.com"
                                                   password:@"applepass"
                                                       host:@"demo.theqvd.com"];
    [[QVDClientWrapper sharedManager] setStatusDelegate:self];
    [[QVDClientWrapper sharedManager] listOfVms];
}

- (void) qvdProgressMessage:(NSString *) aMessage{
    NSLog(@"QVD CLIENT WRAPPER MESSAGE RECEIVED [%@]",aMessage);
}

- (void) vmListRetreived:(NSArray *) aVmList{
    NSLog(@"QVD CLIENT WRAPPER VM LIST RECEIVED [%@]",aVmList);
    QVDVmVO *anVm = [aVmList objectAtIndex:0];
    [[QVDClientWrapper sharedManager] connectToVm:[anVm id]];
}

@end
