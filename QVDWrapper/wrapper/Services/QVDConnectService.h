//
//  QVDConnectService.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 17/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QVDService.h"

@interface QVDConnectService : NSObject

@property (assign,nonatomic) QVDServiceState srvStatus;

-(void)startService;
-(void)stopService;
-(void)setServiceStatus:(QVDServiceState) newStatus;

@end
