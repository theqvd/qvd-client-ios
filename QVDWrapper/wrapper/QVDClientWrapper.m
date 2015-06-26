//
//  QVDClientWrapper.m
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

#import "QVDClientWrapper.h"
#import "QVDConfig.h"
#import "QVDVmVO.h"
#include "qvdclient.h"
#include "qvdvm.h"
#include "curl.h"
#include "QVDProxyService.h"
#include "QVDXvncService.h"
#import "ConnectionVO.h"

#define NETWORK_OPTIONS @[@"Local",@"ADSL",@"Modem"]
#define PLATFORM @"ios"
@interface QVDClientWrapper ()
@property (nonatomic) qvdclient *qvd;
@property (nonatomic) int connect_result;
@property (strong,nonatomic) QVDProxyService *srvProxy;
@property (strong,nonatomic) QVDXvncService *srvXvnc;
@property (assign,nonatomic) BOOL xvncStarted;
@property (nonatomic) int pendingStatus; //0 nothing, 1 listVm, 2connectToVm
@property (assign,nonatomic) BOOL listVmOnStart;
@property (assign,nonatomic) BOOL internalConnect;

@property (strong,nonatomic) ConnectionVO *startConfiguration;


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



-(void)setCredentialsWitConfiguration:(ConnectionVO *)aConfig{
    
    if(aConfig){
        self.startConfiguration = aConfig;
        self.login = [self.startConfiguration qvdDefaultLogin];
        self.pass = [self.startConfiguration qvdDefaultPass];
        self.host = [self.startConfiguration qvdDefaultHost];
        self.port = [self.startConfiguration qvdDefaultPort];
        self.debug = [self.startConfiguration qvdDefaultDebug];
        self.fullscreen = [self.startConfiguration qvdDefaultFullScreen];
        self.width = [self.startConfiguration qvdDefaultWidth];
        self.height = [self.startConfiguration qvdDefaultHeight];
    }
}


-(id)init{
    self = [ super init ];
    if(self){
        _xvncStarted = NO;
        _listVmOnStart = NO;
        _internalConnect = NO;
        _loginAllowed = YES;
        //Credentials
        _name = @"";
        _login = [self.startConfiguration qvdDefaultLogin];
        _pass = [self.startConfiguration qvdDefaultPass];
        _host = [self.startConfiguration qvdDefaultHost];
        //Wrapper configuration
        _qvd = NULL;
        _port = [self.startConfiguration qvdDefaultPort];
        _debug = [self.startConfiguration qvdDefaultDebug];
        _fullscreen = [self.startConfiguration qvdDefaultFullScreen];
        _width = [self.startConfiguration qvdDefaultWidth];
        _height = [self.startConfiguration qvdDefaultHeight];
        _x509certfile = [self.startConfiguration qvdX509Cert];
        _x509keyfile = [self.startConfiguration qvdX509Key];
        _usecertfiles = [self.startConfiguration qvdClientCertificates];
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
    } else {
        self.listVmOnStart = YES;
    }
}

-(BOOL)doInternalConnect{
    if(self.internalConnect){
        return YES;
    }
    if(!self.login || !self.pass || !self.host){
        NSLog(@"User credentials invalid");
        if(self.statusDelegate){
            [self.statusDelegate qvdError:@"User credentials invalid"];
        }
        return NO;
    }
    //Setup debug


    if(self.debug){
        qvd_set_debug();
    }
    //Init qvd client
    self.qvd = qvd_init([self.host UTF8String], self.port, [self.login UTF8String], [self.pass UTF8String]);
    // Set home dir
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *home_path = [[ fm URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil] path];
    qvd_set_home(self.qvd, [home_path UTF8String]);
    qvd_set_no_cert_check(self.qvd);
    
    if(self.usecertfiles){
        qvd_set_cert_files(self.qvd,[self.x509certfile UTF8String],[self.x509keyfile UTF8String]);
    }

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
    if(self.qvd){
        char *messagechar = qvd_get_last_error(self.qvd);
        NSString *qvd_error = [NSString stringWithUTF8String:messagechar];
        if(![qvd_error isEqualToString:@""]){
            [self.statusDelegate qvdError:qvd_error];
            [self resetAfterLoginFailed];
        } else {
            self.internalConnect = NO;
        }
        self.internalConnect  = YES;
        NSLog(@"Tenemos QVD object...");
    } else {
        self.internalConnect  = NO;
        NSLog(@"NO!!!! tenemos qvd object");
    }
    return self.internalConnect;

}

- (void) realListOfVms{



    dispatch_async(dispatch_queue_create("qvdclient", NULL), ^{
        if([self doInternalConnect]){
            //TODO: certificate and progress

            if(self.qvd){
                qvd_list_of_vm(self.qvd);

                char *messagechar = qvd_get_last_error(self.qvd);
                NSString *qvd_error = [NSString stringWithUTF8String:messagechar];
                if(![qvd_error isEqualToString:@""]){
                    [self.statusDelegate qvdError:qvd_error];
                    [self resetAfterLoginFailed];
                    
                } else {
                self.listvm =[self convertVMlistIntoNSArray];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    if(self.statusDelegate){
                        [self.statusDelegate vmListRetrieved:self.listvm];
                    }
                });
                }

            } else {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [self.statusDelegate qvdError: NSLocalizedString(@"messages.error.conenctionFailed",@"Connection failed")];
                });
            }
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
        char *messagechar = qvd_get_last_error(self.qvd);
        NSString *endconnection = [NSString stringWithFormat:@"Connection has finished.%s", messagechar ];
        NSLog(@"%@", endconnection);
        dispatch_async(dispatch_get_main_queue(), ^(){;
            // We free in the main thread to avoid concurrency problems
            qvd_free(self.qvd);
            self.internalConnect = NO;
            if(self.statusDelegate){
                [self.statusDelegate connectionFinished];
                self.loginAllowed = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"QVD_ALLOW_CONNECT" object:self userInfo:nil];

            }
        });
    });
    // self.connect_result = qvd_connect_to_vm(self.qvd, self.selectedvmid);

    NSLog(@"QVDClientWrapper: connectToVm %d with qvd %p result was %d", self.selectedvmid, self.qvd, self.connect_result);
    return self.connect_result;
}



- (void) endConnection:(int) anVmId {
    self.loginAllowed = NO;
    NSLog(@"QVDClientWrapper: endConnection");
    if (self.qvd == NULL) {
        NSLog(@"QVDClientWrapper: endConnection: qvd pointer is null, not ending connection, waiting for init");
        return;
    }
    // This will end the connection thread in connectToVM
    qvd_end_connection(self.qvd);
    //Stop services not needed
    // [self stopServices];
}

#pragma mark - Notification Methods

int progress_callback(qvdclient *qvd, const char *message) {
    NSString *progressMessage = [ [ NSString alloc ] initWithUTF8String: message ];
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
    if(self.listVmOnStart){
        self.listVmOnStart = NO;
        [self realListOfVms];
    }
}

- (void) qvdProgressMessage:(NSString *) aMessage{
    NSLog(@"Message from delegate: [%@]",aMessage);
}

- (void) vmListRetrieved:(NSArray *) aVmList{

}

-(NSString *)getLastError{
    return [NSString stringWithUTF8String:qvd_get_last_error(self.qvd)];
}

-(void)resetAfterLoginFailed{
    _listVmOnStart = NO;
    _internalConnect = NO;
    _loginAllowed = YES;
    if (self.qvd == NULL) {
        NSLog(@"QVDClientWrapper: endConnection: qvd pointer is null, not ending connection, waiting for init");
        return;
    }
    qvd_end_connection(self.qvd);
}


@end
