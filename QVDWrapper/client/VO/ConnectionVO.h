//
//  ConnectionVO.h
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

#import <Foundation/Foundation.h>

@interface ConnectionVO : NSObject

@property (assign,nonatomic) int qvdDefaultPort;
@property (assign,nonatomic) int qvdDefaultWidth;
@property (assign,nonatomic) int qvdDefaultHeight;
@property (assign,nonatomic) int qvdDefaultLinkItem;
@property (assign,nonatomic) BOOL qvdDefaultDebug;
@property (assign,nonatomic) BOOL qvdDefaultFullScreen;
@property (strong,nonatomic) NSString *qvdDefaultLogin;
@property (strong,nonatomic) NSString *qvdDefaultPass;
@property (strong,nonatomic) NSString *qvdDefaultHost;

@property (assign,nonatomic) BOOL qvdClientCertificates;
@property (strong,nonatomic) NSString *qvdX509Cert;
@property (strong,nonatomic) NSString *qvdX509Key;


+(id)initWithDetauls;


@end
