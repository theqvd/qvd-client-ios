//
//  QVDClientWrapper.h
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
//  Created by Oscar Costoya Vidal on 14/3/15.
//

#import <Foundation/Foundation.h>
#import "QVDConfig.h"
#import "ConnectionVO.h"

@protocol QVDStatusDelegate

    @optional
    - (void) qvdProgressMessage:(NSString *) aMessage;
    - (void) vmListRetrieved:(NSArray *) aVmList;
    - (void) qvdError:(NSString *)aMessage;
    - (void) connectionFinished;

@end

@interface QVDClientWrapper : NSObject

    @property (strong,nonatomic) NSString *name;
    @property (strong,nonatomic) NSString *login;
    @property (strong,nonatomic) NSString *pass;
    @property (strong,nonatomic) NSString *host;
    @property (strong,nonatomic) NSString *x509certfile;
    @property (strong,nonatomic) NSString *x509keyfile;
    @property (strong,nonatomic) NSString *homedir;
    @property (strong,nonatomic) NSString *os;
    @property (nonatomic) int port, selectedvmid, width, height, linkitem;
    @property (nonatomic) BOOL debug, fullscreen, usecertfiles, mockConnection;
    @property (strong,nonatomic) NSArray *listvm;
    @property (strong,nonatomic) NSArray *linkTypes;
    @property (strong,nonatomic) id<QVDStatusDelegate> statusDelegate;
    @property (assign,nonatomic) BOOL loginAllowed;

    + (id)sharedManager;
    -(void)setCredentialsWitConfiguration:(ConnectionVO *)aConfig;
    //-(id)initWithUser:(NSString *) anUser password:(NSString *)anPassword host:(NSString *) anHost;
    -(void)listOfVms;
    -(void)listOfVmsWithConfig:(ConnectionVO *)aConfig;
    -(int)connectToVm:(int) anVmId;
    -(int)stopVm;
    -(void) endConnection:(int) anVmId;
    -(NSString *)getLastError;

@end
