//
//  QVDConfig.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 8/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "QVDConfig.h"

@implementation QVDConfig

+(id)configWithDefaults{
    QVDConfig *aux = [[QVDConfig alloc] init];
    if(aux){
        aux.wsHost = "127.0.0.1";
        aux.wsPort = 5800;
        aux.wsStartupTimeout = 10;
        aux.wsCheckTimeout = 20000; //20s
        aux.xvncHost = "127.0.0.1";
        aux.xvncDisplay = "127.0.0.1:0";
        aux.xvncPassword = "ben1to";
        aux.xvncVncPort = 5900;
        aux.xvncStartupTimeout = 15;
        aux.xvncXDisplayPort = 5900;
        aux.xvncCheckTimeout = 20000;
        aux.noVncTopFrameHeight = 36;
        
        aux.qvdDefaultWidth = 1024;
        aux.qvdDefaultHeight = 768;
        aux.qvdDefaultLinkItem = 1;
        aux.qvdDefaultPort = 8443;
        aux.qvdDefaultDebug = YES;
        aux.qvdUseMock = NO;
        aux.qvdDefaultFullScreen = YES;
        
        //TODO: Remove from release, pending conditional constant definition for develop
        aux.qvdDevelop = YES;
        aux.qvdDefaultLogin = @"appledevprogram@qindel.com";
        aux.qvdDefaultPass = @"applepass";
        aux.qvdDefaultHost = @"demo.theqvd.com";
    }
    return aux;
}

@end
