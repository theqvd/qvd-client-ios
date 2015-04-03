//
//  QVDClientWrapper.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 14/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <Foundation/Foundation.h>

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

-(id)initWithUser:(NSString *) anUser password:(NSString *)anPassword host:(NSString *) anHost;
-(void)listOfVms;
-(int)connectToVm;
-(int)stopVm;
-(void)disconnect;

@end
