//
//  QVDConfig.m
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

#import "QVDConfig.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface QVDConfig()
- (void) setGeometry;
@end

@implementation QVDConfig

+(id)configWithDefaults{
    QVDConfig *aux = [[QVDConfig alloc] init];
    if(aux){
        aux.wsHost = "127.0.0.1";
        aux.wsPort = 5800;
        aux.wsStartupTimeout = 10;
        aux.wsCheckTimeout = 20; //20s
        aux.xvncHost = "127.0.0.1";
        aux.xvncFullDisplay = "127.0.0.1:0";
        aux.xvncDisplay = ":0";
        aux.xvncPassword = "ben1to";
        aux.xvncVncPort = 5910;
        aux.xvncStartupTimeout = 15;
        aux.xvncXDisplayPort = 6000;
        aux.xvncCheckTimeout = 20000;
        aux.noVncTopFrameHeight = 20; // was 36

        aux.qvdDefaultWidth = 1024;
        aux.qvdDefaultHeight = 768;
        aux.qvdDefaultLinkItem = 1;
        aux.qvdDefaultPort = 8443;
        aux.qvdDefaultDebug = NO;
        aux.qvdUseMock = NO;
        aux.qvdDefaultFullScreen = NO;

        //TODO: Remove from release, pending conditional constant definition for develop
        aux.qvdDevelop = YES;
        aux.qvdDefaultLogin = @"appledevprogram@qindel.com";
        aux.qvdDefaultPass = @"applepass";
        aux.qvdDefaultHost = @"demo.theqvd.com";
    }
    [ aux setGeometry];
    return aux;
}

- (void) setGeometry {
    CGFloat currentWidth = MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    CGFloat currentHeight = MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) - self.noVncTopFrameHeight;
    self.qvdDefaultWidth = (int) currentWidth;
    self.qvdDefaultHeight = (int) currentHeight;
    NSLog(@"Current geometry: %f | %f",currentWidth,currentHeight);
}

@end
