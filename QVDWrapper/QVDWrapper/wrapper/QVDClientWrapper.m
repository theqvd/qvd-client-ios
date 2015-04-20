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
#include "QVDProxyService.h"
#include "QVDXvncService.h"

#define NETWORK_OPTIONS @[@"Local",@"ADSL",@"Modem"]
#define PLATFORM @"ios"
@interface QVDClientWrapper ()
    @property (nonatomic) qvdclient *qvd;
    @property (nonatomic) int connect_result;
    @property (strong,nonatomic) QVDProxyService *srvProxy;
    @property (strong,nonatomic) QVDXvncService *srvXvnc;
    @property (assign,nonatomic) BOOL xvncStarted;
    @property (nonatomic) int pendingStatus; //0 nothing, 1 listVm, 2connectToVm

@end

@implementation QVDClientWrapper

+ (id)sharedManager {
    static QVDClientWrapper *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

-(void)setCredentialsWitUser:(NSString *) anUser password:(NSString *)anPassword host:(NSString *) anHost{
    self.login = anUser ? anUser : @"";
    self.pass = anPassword ? anPassword : @"";
    self.host = anHost ? anHost : @"";
}


-(id)init{
    self = [ super init ];
    if(self){
        QVDConfig *configuration = [QVDConfig configWithDefaults];
        _xvncStarted = NO;
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
        _width = [[UIScreen mainScreen] bounds].size.width;
        _height = [[UIScreen mainScreen] bounds].size.height;
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
    vms = [[NSMutableArray alloc] init];
    if (self.qvd->vmlist == NULL) {
        return nil;
    }

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

-(void) listOfVms{
    if([self servicesRunning]){
        [self realListOfVms];
    }
}


- (void) realListOfVms{
    if(!self.login || !self.pass || !self.host){
        NSLog(@"User credentials invalid");
        return;
    }
    //Setup debug
        dispatch_async(dispatch_queue_create("qvdclient", NULL), ^{
    if(self.debug){
        qvd_set_debug();
    }
    //Init qvd client
    self.qvd = qvd_init([self.host UTF8String], self.port, [self.login UTF8String], [self.pass UTF8String]);
    
    //TODO: certificate and progress
    qvd_set_no_cert_check(self.qvd);
    qvd_set_progress_callback(self.qvd, progress_callback);
    
    if(self.fullscreen){
        qvd_set_fullscreen(self.qvd);
    }
    
    qvd_set_geometry(self.qvd, [[self getGeometry] UTF8String]);
    
    qvd_set_os(self.qvd, self.os.UTF8String);
    
    if (self.homedir){
        qvd_set_home(self.qvd,self.homedir.UTF8String);
    }
    
    qvd_set_display(self.qvd, [[QVDConfig configWithDefaults] xvncFullDisplay]);
    
    if (curl_easy_setopt(self.qvd->curl, CURLOPT_NOSIGNAL, 1) != CURLE_OK) {
        NSLog(@"Error setting CURLOPT_NOSIGNAL");
    }
    
    qvd_list_of_vm(self.qvd);
    if(self.qvd){
        self.listvm =[self convertVMlistIntoNSArray];
        dispatch_async(dispatch_get_main_queue(), ^(){
            if(self.statusDelegate){
                [self.statusDelegate vmListRetrieved:self.listvm];
            }
        });
        
    }
        });
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

- (int) connectToVm:(int) anVmId {
    NSLog(@"QVDClientWrapper: connectToVM");
    if (self.qvd == NULL) {
        NSLog(@"QVDClientWrapper: connectToVm: Error qvd pointer is NULL, returning -1");
        return -1;
    }
    if(anVmId){
        self.selectedvmid = anVmId;
    }
    NSLog(@"QVDClientWrapper: connectToVm %d with qvd %p", self.selectedvmid, self.qvd);
    dispatch_async(dispatch_queue_create("qvdclient", NULL), ^{
        qvd_connect_to_vm(self.qvd, self.selectedvmid);
        // TODO there should probably be a notification here
    });
   // self.connect_result = qvd_connect_to_vm(self.qvd, self.selectedvmid);
    
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
    //Stop services
    [self stopServices];
}

#pragma mark - Notification Methods

int progress_callback(qvdclient *qvd, const char *message) {
    NSString *progressMessage = [ [ NSString alloc ] initWithUTF8String: message ];
    NSLog(@"======> Progress message [%@]",progressMessage);
    if([[QVDClientWrapper sharedManager] statusDelegate]){
        [[[QVDClientWrapper sharedManager] statusDelegate] qvdProgressMessage:progressMessage];
    }
    return 1;
}

//TODO: Pending check....

int accept_unknown_cert_callback(qvdclient *qvd, const char *cert_pem_str, const char *cert_pem_data) {
    int result=0;
    NSString *pemstr, *pemdata;
    NSLog(@"QVDClientWrapper: accept_unknown_cert_callback (%s, %s)", cert_pem_str, cert_pem_data);
    pemstr = [ [ NSString alloc ] initWithUTF8String: cert_pem_str ];
    pemdata = [ [ NSString alloc ] initWithUTF8String: cert_pem_data ];

    
    return result;
}

#pragma mark - Service Status

-(void)stopServices{
    if(self.xvncStarted){
        [self.srvProxy stopService];
        [self.srvXvnc stopService];
    }
}

-(BOOL)servicesRunning{
    if(!self.xvncStarted){
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(xvncServiceStarted)
                                                     name:@"QVDXVNCServiceStarted"
                                                   object:nil];

        self.srvProxy=  [[QVDProxyService alloc] init];
        self.srvXvnc =  [[QVDXvncService alloc] init];
        [self.srvXvnc startService];
        [self.srvProxy startService];
        return NO;
    } else {
        return YES;
    }
}

-(void)xvncServiceStarted{
    self.xvncStarted = YES;
    [self listOfVms];
}

- (void) qvdProgressMessage:(NSString *) aMessage{
    NSLog(@"Message from delegate: [%@]",aMessage);
}

- (void) vmListRetrieved:(NSArray *) aVmList{
    
}

-(NSString *)getLastError{
    return [NSString stringWithUTF8String:qvd_get_last_error(self.qvd)];
}


@end
