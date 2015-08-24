//
//  ConnectionVO.m
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
//  Created by Oscar Costoya Vidal on 13/4/15.
//

#import "ConnectionVO.h"
#import "QVDConfig.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation ConnectionVO

+(id)initWithDetauls{
    ConnectionVO *aux = [[ConnectionVO alloc] init];
    if(aux){
        [aux setQvdDefaultPort:QVD_DEFAULT_PORT];
        [aux setQvdDefaultFullScreen:NO];
        [aux setQvdDefaultDebug:NO];
        [aux setQvdClientCertificates:NO];
        [aux setGeometry];
    }
    return aux;
}

- (void) setGeometry {
    float offset = [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone ? 20. : 10.;
    CGFloat currentWidth = MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    CGFloat currentHeight = MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) - (44. + offset);
    self.qvdDefaultWidth = (int) currentWidth;
    self.qvdDefaultHeight = (int) currentHeight;
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

@end
