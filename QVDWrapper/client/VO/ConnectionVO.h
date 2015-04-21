//
//  ConnectionVO.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 13/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionVO : NSObject

@property (strong,nonatomic) NSString *userLogin;
@property (strong,nonatomic) NSString *userPassword;
@property (strong,nonatomic) NSString *qvdHost;

+(id)initWithUser:(NSString *)aUser andPassword:(NSString *)aPassword andHost:(NSString *) aHost;


@end
