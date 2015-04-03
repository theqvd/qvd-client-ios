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
#include "tcpconnect.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startXVNC)
                                                 name:@"QVDProxyServiceStarted"
                                               object:nil];
}


-(void)viewDidAppear:(BOOL)animated{
    QVDProxyService *proxyService =  [[QVDProxyService alloc] init];
    [proxyService startService];

}

-(void)viewDidDisappear:(BOOL)animated{
    NSLog(@"Desaparezzzzzzco......");
}

-(void)startXVNC{
    NSLog(@"STAAAAAAAART XVNC");
    QVDXvncService *xvncService =  [[QVDXvncService alloc] init];
    [xvncService startService];
}



@end
