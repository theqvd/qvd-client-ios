//
//  ConnectionVO.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 13/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "ConnectionVO.h"

@implementation ConnectionVO

+(id)initWithUser:(NSString *)aUser andPassword:(NSString *)aPassword andHost:(NSString *) aHost{
    ConnectionVO *aux = [[ConnectionVO alloc] init];
    if(aux){
        [aux setUserLogin:aUser];
        [aux setUserPassword:aPassword];
        [aux setQvdHost:aHost];
    }
    return aux;
}

@end
