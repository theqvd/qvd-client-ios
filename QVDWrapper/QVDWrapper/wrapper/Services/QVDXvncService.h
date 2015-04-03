//
//  QVDXvncService.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 14/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QVDService.h"

@interface QVDXvncService : NSObject

@property (assign,nonatomic) QVDServiceState srvStatus;
-(void)startService;
-(void)stopService;
-(void)setServiceStatus:(QVDServiceState) newStatus;

@end
