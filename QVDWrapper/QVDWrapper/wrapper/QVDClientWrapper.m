//
//  QVDClientWrapper.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 14/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "QVDClientWrapper.h"
#import "QVDConfig.h"
#import "QVDVmVO.h"
#include "qvdclient.h"
#include "qvdvm.h"
#include "curl.h"

#define NETWORK_OPTIONS @[@"Local",@"ADSL",@"Modem"]
#define PLATFORM @"ios"
@interface QVDClientWrapper ()
    @property (nonatomic) qvdclient *qvd;
    @property (nonatomic) int connect_result;
@end

@implementation QVDClientWrapper


-(id)init{
    self = [ super init ];
    if(self){
        QVDConfig *configuration = [QVDConfig configWithDefaults];
        //Credentials
        _name = @"";
        _login = @"";
        _pass = @"";
        _host = @"";
        //Wrapper configuration
        _qvd = NULL;
        _port = 8443;
        _debug = [configuration qvdDefaultDebug];
        _fullscreen = [configuration qvdDefaultFullScreen];
        _width = [configuration qvdDefaultWidth];
        _height = [configuration qvdDefaultHeight];
        _x509certfile = @"";
        _x509keyfile = @"";
        _usecertfiles = NO;
        _os = PLATFORM;
        //Network options
        _linkitem = 1; // By default ADSL
        //Vm list
        
        NSFileManager *fm = [ NSFileManager new];
        NSError *err = nil;
        NSURL * suppurl = [ fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:&err];
        if (err != nil) {
            NSLog(@"QVDClientWrapper: Error creating Application support directory %@", err);
            _homedir = nil;
        } else {
            _homedir = [ suppurl path ];
        }
    }
    return self;
}

-(id)initWithUser:(NSString *) anUser password:(NSString *)anPassword host:(NSString *) anHost{
    self = [self init];
    if(self){
        _login = anUser ? anUser : @"";
        _pass = anPassword ? anPassword : @"";
        _host = anHost ? anHost : @"";
    }
    return self;
}

- (NSString *) name {
    NSString *d = self.name;
    if ((!d || [ d isEqualToString:@""])
        && self.login && self.host &&
        (![self.login isEqualToString:@""]) &&
        (![self.host isEqualToString:@""])) {
        d = [[NSString alloc] initWithFormat:@"%@@%@", self.login, self.host];
        self.name = d;
    }
    return self.name;
}

- (NSMutableArray *) convertVMlistIntoNSArray {
    int i;
    vmlist *vm_ptr;
    NSMutableArray *vms = nil;
    
    if (self.qvd->vmlist == NULL) {
        return nil;
    }
    vms = [[NSMutableArray alloc] initWithCapacity:self.qvd->numvms];
    for (vm_ptr = self.qvd->vmlist, i=0; i < self.qvd->numvms; ++i, vm_ptr = vm_ptr->next) {
        if (vm_ptr == NULL) {
            NSLog(@"QVDClientWrapper: Internal error converting vmlist in position %d, pointer is null and should not be", i);
            return nil;
        }
        vm *data = vm_ptr->data;
        if (data == NULL) {
            NSLog(@"QVDClientWrapper: Internal error converting vmlist in position %d, data pointer is null and should not be", i);
            return nil;
        }
        
        QVDVmVO *vm = [[QVDVmVO alloc] initWithId:data->id
                                         andName:data->name
                                        andState:data->state
                                      andBlocked:data->blocked];
        [ vms addObject:vm];
    }
    return vms;
}


-(NSString *)getGeometry{
    return [NSString stringWithFormat:@"%dx%d",self.width,self.height];
}

#pragma mark - VM Methods

- (void) listOfVms{
    if(!self.login && !self.pass && !self.host){
        NSLog(@"User credentials invalid");
        return;
    }
    //Setup debug
    if(self.debug){
        qvd_set_debug();
    }
    //Init qvd client
    self.qvd = qvd_init([self.host UTF8String], self.port, [self.login UTF8String], [self.pass UTF8String]);
    
    //TODO: certificate and progress
    
    if(self.fullscreen){
        qvd_set_fullscreen(self.qvd);
    }
    
    qvd_set_geometry(self.qvd, [[self getGeometry] UTF8String]);
    
    qvd_set_os(self.qvd, self.os.UTF8String);
    
    if (self.homedir){
        qvd_set_home(self.qvd,self.homedir.UTF8String);
    }
    
    qvd_set_display(self.qvd, [[QVDConfig configWithDefaults] xvncDisplay]);
    if (curl_easy_setopt(self.qvd->curl, CURLOPT_NOSIGNAL, 1) != CURLE_OK) {
        NSLog(@"Error setting CURLOPT_NOSIGNAL");
    }
    
    qvd_list_of_vm(self.qvd);
    if(self.qvd){
        self.listvm =[self convertVMlistIntoNSArray];
    }
}

- (int) stopVm {
    NSLog(@"QVDClientWrapper: stopVm");
    if (!self.qvd) {
        NSLog(@"QVDClientWrapper: stopVm: Error qvd pointer is NULL, returning -1");
        return -1;
    }

    self.connect_result = qvd_stop_vm(self.qvd, self.selectedvmid);
    NSLog(@"QVDClientWrapper: stopVm %d with qvd %p result was %d", self.selectedvmid, self.qvd, self.connect_result);
    return self.connect_result;
}

- (int) connectToVm {
    NSLog(@"QVDClientWrapper: connectToVM");
    if (self.qvd == NULL) {
        NSLog(@"QVDClientWrapper: connectToVm: Error qvd pointer is NULL, returning -1");
        return -1;
    }
    NSLog(@"QVDClientWrapper: connectToVm %d with qvd %p", self.selectedvmid, self.qvd);
    
    self.connect_result = qvd_connect_to_vm(self.qvd, self.selectedvmid);
    
    NSLog(@"QVDClientWrapper: connectToVm %d with qvd %p result was %d", self.selectedvmid, self.qvd, self.connect_result);
    return self.connect_result;
}

- (void) endConnection {
    NSLog(@"QVDClientWrapper: endConnection");
    if (self.qvd == NULL) {
        NSLog(@"QVDClientWrapper: endConnection: qvd pointer is null, not ending connection, waiting for init");
        return;
    }
    qvd_end_connection(self.qvd);
}

@end
