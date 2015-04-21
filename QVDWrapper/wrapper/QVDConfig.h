//
//  QVDConfig.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 8/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QVDConfig : NSObject

//WS Properties
@property (assign,nonatomic) char *wsHost;
@property (assign,nonatomic) int wsPort;
@property (assign,nonatomic) int wsStartupTimeout;
@property (assign,nonatomic) int wsCheckTimeout;
//XVNC Properties
@property (assign,nonatomic) char *xvncHost;
@property (assign,nonatomic) char *xvncFullDisplay;
@property (assign,nonatomic) char *xvncDisplay;
@property (assign,nonatomic) char *xvncPassword;
@property (assign,nonatomic) int xvncVncPort;
@property (assign,nonatomic) int xvncStartupTimeout;
@property (assign,nonatomic) int xvncCheckTimeout;
@property (assign,nonatomic) int xvncXDisplayPort;
@property (assign,nonatomic) int noVncTopFrameHeight;

@property (assign,nonatomic) int qvdDefaultPort;
@property (assign,nonatomic) int qvdDefaultWidth;
@property (assign,nonatomic) int qvdDefaultHeight;
@property (assign,nonatomic) int qvdDefaultLinkItem;
@property (assign,nonatomic) BOOL qvdUseMock;
@property (assign,nonatomic) BOOL qvdDefaultDebug;
@property (assign,nonatomic) BOOL qvdDefaultFullScreen;
@property (assign,nonatomic) BOOL qvdDevelop;
@property (strong,nonatomic) NSString *qvdDefaultLogin;
@property (strong,nonatomic) NSString *qvdDefaultPass;
@property (strong,nonatomic) NSString *qvdDefaultHost;

+(id)configWithDefaults;

@end
