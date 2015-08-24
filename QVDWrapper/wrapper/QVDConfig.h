//
//  QVDConfig.h
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
//  Created by Oscar Costoya Vidal on 8/3/15.
//

#import <Foundation/Foundation.h>

#define QVD_DEFAULT_PORT 8443
#define QVD_DEFAULT_FULL_SCREEN NO
#define QVD_DEFAULT_DEBUG NO

#define XVNC_FULL_DISPLAY "127.0.0.1:0"

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

@property (assign,nonatomic) BOOL qvdClientCertificates;
@property (strong,nonatomic) NSString *qvdX509Cert;
@property (strong,nonatomic) NSString *qvdX509Key;

+(id)configWithDefaults;
+(NSString *)aboutInfo;

@end
