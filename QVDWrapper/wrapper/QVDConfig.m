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
        //aux.xvncFullDisplay = "127.0.0.1:0";
        aux.xvncDisplay = ":0";
        aux.xvncPassword = "ben1to";
        aux.xvncVncPort = 5910;
        aux.xvncStartupTimeout = 15;
        aux.xvncXDisplayPort = 6000;
        aux.xvncCheckTimeout = 20000;
        aux.noVncTopFrameHeight = 44.;
        aux.qvdDefaultWidth = 1024;
        aux.qvdDefaultHeight = 768;
        aux.qvdDefaultLinkItem = 1;
        aux.qvdDefaultPort = 8443;
        aux.qvdDefaultDebug = YES;
        aux.qvdUseMock = NO;
        aux.qvdDefaultFullScreen = NO;
        aux.qvdDevelop = YES;
        aux.qvdDefaultLogin = @"";
        aux.qvdDefaultPass = @"";
        aux.qvdDefaultHost = @"";
        [aux setGeometry];
    }

    return aux;
}

- (void) setGeometry {
    CGFloat currentWidth = MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    CGFloat currentHeight = MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) - (self.noVncTopFrameHeight);
    self.qvdDefaultWidth = (int) currentWidth;
    self.qvdDefaultHeight = (int) currentHeight;
    NSLog(@"QVDConfig Current geometry: %f | %f",currentWidth,currentHeight);
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeInt:self.qvdDefaultPort forKey:@"qvdDefaultPort"];
    [encoder encodeInt:self.qvdDefaultWidth forKey:@"qvdDefaultWidth"];
    [encoder encodeInt:self.qvdDefaultHeight forKey:@"qvdDefaultHeight"];
    [encoder encodeInt:self.qvdDefaultLinkItem forKey:@"qvdDefaultLinkItem"];
    [encoder encodeBool:self.qvdDefaultDebug forKey:@"qvdDefaultDebug"];
    [encoder encodeBool:self.qvdDefaultFullScreen forKey:@"qvdDefaultFullScreen"];
    [encoder encodeObject:self.qvdDefaultLogin forKey:@"qvdDefaultLogin"];
    [encoder encodeObject:self.qvdDefaultPass forKey:@"qvdDefaultPass"];
    [encoder encodeObject:self.qvdDefaultHost forKey:@"qvdDefaultHost"];
    
    [encoder encodeBool:self.qvdClientCertificates forKey:@"qvdClientCertificates"];
    [encoder encodeObject:self.qvdX509Cert forKey:@"qvdX509Cert"];
    [encoder encodeObject:self.qvdX509Key forKey:@"qvdX509Key"];
    
    
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [QVDConfig configWithDefaults];
    if(self) {
        self.qvdDefaultPort = [decoder decodeIntForKey:@"qvdDefaultPort"];
        self.qvdDefaultWidth = [decoder decodeIntForKey:@"qvdDefaultWidth"];
        self.qvdDefaultHeight = [decoder decodeIntForKey:@"qvdDefaultHeight"];
        self.qvdDefaultLinkItem = [decoder decodeIntForKey:@"qvdDefaultLinkItem"];
        self.qvdDefaultDebug = [decoder decodeBoolForKey:@"qvdDefaultDebug"];
        self.qvdDefaultFullScreen = [decoder decodeBoolForKey:@"qvdDefaultFullScreen"];
        self.qvdDefaultLogin = [decoder decodeObjectForKey:@"qvdDefaultLogin"];
        self.qvdDefaultPass = [decoder decodeObjectForKey:@"qvdDefaultPass"];
        self.qvdDefaultHost = [decoder decodeObjectForKey:@"qvdDefaultHost"];
        self.qvdClientCertificates = [decoder decodeBoolForKey:@"qvdClientCertificates"];
        self.qvdX509Cert = [decoder decodeObjectForKey:@"qvdX509Cert"];
        self.qvdX509Key = [decoder decodeObjectForKey:@"qvdX509Key"];
    }
    return self;
}

+(NSString *)aboutInfo{
    const char *libqvdversion = qvd_get_version_text();
    NSString *libqvdversionstr = [NSString stringWithUTF8String:libqvdversion];
    NSString *appversion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *localizedInfo = NSLocalizedString(@"common.titleAbout",@"About");
    NSString *aboutinfo = [NSString stringWithFormat:@"%@\rVersion: %@\r%@\r", localizedInfo, appversion, libqvdversionstr];

    return  aboutinfo;
}

@end
