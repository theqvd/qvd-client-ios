//
//  QVDProxyService.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 10/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "QVDProxyService.h"
#include "websocket.h"
#include "tcpconnect.h"

#define SERVICE_QUEUE "com.qindel.qvd.proxy"
#define SERVICE_CHECK "com.qindel.qvd.proxycheck"


@interface QVDProxyService ()

@property (strong,nonatomic) NSTimer *checker;
@property (nonatomic) dispatch_queue_t serviceQueue;
@property (nonatomic) dispatch_queue_t controlQueue;
@property (nonatomic) dispatch_group_t group;
@property BOOL doCheck;

@end

@implementation QVDProxyService


-(id)init{
    self = [super init];
    if(self){
        _serviceQueue =  dispatch_queue_create(SERVICE_QUEUE, NULL);
        _controlQueue = dispatch_queue_create(SERVICE_CHECK, NULL);
        _group = dispatch_group_create();
        self.doCheck = NO;
    }
    return self;
}

-(void)startService{
    

    
  __weak typeof(self) weakSelf = self;
    
    [self initControl];
    [self setServiceStatus:SRV_STARTED_PENDING_CHECK];
     [weakSelf notificateServiceChanged:@"QVDProxyServiceStarting"];
    dispatch_group_async(_group, self.serviceQueue, ^{
        int result = websockify(1, "127.0.0.1", 5800, "127.0.0.1", 5900);
        [weakSelf logToMainThread:[NSString stringWithFormat:@"El resultado del socketServer es: %d",result]];
        if(result == 1){
            [weakSelf stopControl];
            [weakSelf logToMainThread:@"############## Error launching service"];
            [weakSelf notificateServiceChanged:@"QVDProxyServiceErrorOnStart"];
            [weakSelf setServiceStatus:SRV_FAILED];
        }
    });
    
}

-(void)checkDependencies{
    NSLog(@"[QVDProxyService]->[checkDependencies]");
}

-(void)stopService{
    NSLog(@"[QVDProxyService]->[stopService]");
    if([self getSrvStatus] == SRV_STARTED){
        websockify_stop();
    }
}

//Private methods

//TODO: Allow control both request start|stop
-(void)initControl{
    if(!self.doCheck){
        __strong typeof(self) weakSelf = self;
         dispatch_group_async(_group, self.controlQueue, ^{
             weakSelf.doCheck = YES;
             [weakSelf logToMainThread:@"Start control service"];
             while(weakSelf.doCheck){
                 int result = wait_for_tcpconnect("127.0.0.1", 5800, 1, 0);
                 if (result != 0) {
                     [weakSelf logToMainThread:@"Service check error...."];
                 } else {
                     
                     if([weakSelf getSrvStatus] == SRV_STARTED_PENDING_CHECK){
                         [weakSelf setServiceStatus:SRV_STARTED];
                         [weakSelf notificateServiceChanged:@"QVDProxyServiceStarted"];
                         [weakSelf stopControl];
                     } else{
                         [weakSelf logToMainThread:@"Service check success... no stopControl"];
                     }
                 }
                 [NSThread sleepForTimeInterval:.5f];
             }
         });
    }

}

-(void)logToMainThread:(NSString *)log{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"[ QVDProxyService ] %@", log);
    });
}

-(void)stopControl{
    if(self.doCheck){
        self.doCheck = NO;
    }
}

-(void)setServiceStatus:(QVDServiceState) newStatus{
    self.srvStatus = newStatus;
}

-(QVDServiceState)getSrvStatus{
    return self.srvStatus;
}

-(void)notificateServiceChanged:(NSString *) aNotificationName{
    [[NSNotificationCenter defaultCenter] postNotificationName:aNotificationName object:self userInfo:nil];
}

@end
