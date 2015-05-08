//
//  QVDProxyService.m
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
//  Created by Oscar Costoya Vidal on 10/3/15.
//

#import "QVDProxyService.h"
#import "QVDConfig.h"
#include "websocket.h"
#include "tcpconnect.h"

#define SERVICE_QUEUE "com.qindel.qvd.proxy"
#define SERVICE_CHECK "com.qindel.qvd.proxycheck"


@interface QVDProxyService ()

@property (strong,nonatomic) NSTimer *checker;
@property (nonatomic) dispatch_queue_t serviceQueue;
@property (nonatomic) dispatch_queue_t controlQueue;
@property (nonatomic) dispatch_group_t group;
@property (nonatomic) QVDConfig *cfg;
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
        self.cfg = [QVDConfig configWithDefaults];
    }
    return self;
}

-(void)startService{



  __weak typeof(self) weakSelf = self;

    [self initControl];
    [self setServiceStatus:SRV_STARTED_PENDING_CHECK];
     [weakSelf notificateServiceChanged:@"QVDProxyServiceStarting"];
    dispatch_group_async(_group, self.serviceQueue, ^{
        int result = websockify(1, self.cfg.wsHost, self.cfg.wsPort, self.cfg.xvncHost, self.cfg.xvncVncPort);
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
        NSLog(@"[QVDProxyService]->[stopService] websockify_stop()");
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
                 // TODO change timeout
                 int result = wait_for_tcpconnect(self.cfg.wsHost, self.cfg.wsPort, 0, 200000);
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
                 // TODO change timeout
                 [NSThread sleepForTimeInterval:.2f];
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
