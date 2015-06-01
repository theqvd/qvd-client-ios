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

@implementation ConnectionVO

+(id)initWithDetauls{
    ConnectionVO *aux = [[ConnectionVO alloc] init];
    if(aux){
        [aux setQvdDefaultPort:QVD_DEFAULT_PORT];
        [aux setQvdDefaultFullScreen:NO];
        [aux setQvdDefaultDebug:NO];
    }
    return aux;
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
    }
    return self;
}

@end
