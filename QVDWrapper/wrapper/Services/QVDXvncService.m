//
//  QVDXvncService.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 14/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "QVDXvncService.h"
#import "QVDConfig.h"
#define SERVICE_QUEUE "com.qindel.qvd.xvnc"
#define SERVICE_CHECK "com.qindel.qvd.xvnccheck"
#include "qvdxvnc.h"
#include "unistd.h"
#include "stdio.h"
#include "websocket.h"
#include "tcpconnect.h"

#define MAXPATH 2048

const int NOVNC_TOP_FRAME_HEIGHT = 36;


@interface QVDXvncService ()

@property (strong,nonatomic) NSTimer *checker;
@property (nonatomic) dispatch_queue_t serviceQueue;
@property (nonatomic) dispatch_queue_t controlQueue;
@property (nonatomic) dispatch_group_t group;
@property BOOL doCheck;
@property BOOL initialCheck;
@property (nonatomic) QVDConfig *cfg;

//Properties
@property (strong,nonatomic) NSString *basePath;
@property (strong,nonatomic) NSString *fontPath;
@property (strong,nonatomic) NSString *passwordPath;
@property (strong,nonatomic) NSString *passwordArgPath;
@property (strong,nonatomic) NSString *rfbPort;
@end

@implementation QVDXvncService

//Connection parameters
static char fontpathchr[MAXPATH];
static char geometrychr[MAXPATH];
static char passwdargchr[MAXPATH];
static char rfbport[MAXPATH];

-(id)init{
    self = [super init];
    if(self){
        _serviceQueue =  dispatch_queue_create(SERVICE_QUEUE, NULL);
        _controlQueue = dispatch_queue_create(SERVICE_CHECK, NULL);
        _group = dispatch_group_create();
        _initialCheck = YES;
        _basePath = nil;
        _fontPath = nil;
        _passwordPath = nil;
        _passwordArgPath = nil;
        self.doCheck = NO;
        self.cfg = [QVDConfig configWithDefaults];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(realStart)
                                                     name:@"allowStart"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopBeforeStart)
                                                     name:@"stopBeforeStart"
                                                   object:nil];
    }
    return self;
}



-(void)startService{
    [self generateParameters];
    [self initControl];
    
}

-(void)realStart{
    self.initialCheck = NO;
    self.doCheck = NO;
    [self initControl];
    [self setServiceStatus:SRV_STARTED_PENDING_CHECK];
    __weak typeof(self) weakSelf = self;
    [weakSelf notificateServiceChanged:@"QVDXVNCServiceStarting"];
    dispatch_group_async(_group, self.serviceQueue, ^{
        
    char *myargv[] = {"Xvnc",self.cfg.xvncDisplay,"-br","-geometry", geometrychr,"-pixelformat", "rgb888","-pixdepths", "1","4","8","15","16","24","32","+xinerama","+render","-CompareFB=0","-rfbport",rfbport,"-desktop=QVD",passwdargchr,"-fp",fontpathchr,"-ac","-Log","*:stderr:100"};
//        char *myargv[] = {"Xvnc",":0","-br","-geometry", geometrychr,"-pixelformat", "rgb888","-pixdepths", "1","4","8","15","16","24","32","+xinerama","+render","-CompareFB=0","-rfbport",rfbport,"-desktop=QVD",passwdargchr,"-fp",fontpathchr,"-ac","-Log","*:stderr:100"};
//        char *myargv[] = {"Xvnc",":0","-br","-geometry", geometrychr,"-pixelformat", "rgb888","-pixdepths", "1","4","8","15","16","24","32","+xinerama","+render","-CompareFB=0","-desktop=QVD",passwdargchr,"-fp",fontpathchr,"-ac","-Log","*:stderr:100"};
        NSLog(@"Xvnc args: %s", *myargv);
        int myargc=sizeof(myargv)/sizeof(char *);
        if (chdir([[weakSelf getBasePath] UTF8String])<0){
            perror("chdir");
            NSLog(@"Error in chdir into %@", [weakSelf getBasePath]);
            [weakSelf setServiceStatus:SRV_FAILED];
            [weakSelf notificateServiceChanged:@"QVDXVNCServiceErrorOnStart"];
        }else{
            NSLog(@"chdir into %@ ok", [weakSelf getBasePath]);
            
            dix_main(myargc, myargv, nil);
        }
        
    });
}

-(void)stopBeforeStart{
    self.initialCheck = NO;
    self.doCheck = NO;
    dix_main_end();
    [self realStart];
}

-(void)logToMainThread:(NSString *)log{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSLog(@"[ QVDXvncService ] %@", log);
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

-(void)initControl{
    if(!self.doCheck){
        __strong typeof(self) weakSelf = self;
        dispatch_group_async(_group, self.controlQueue, ^{
            weakSelf.doCheck = YES;
            [weakSelf logToMainThread:@"Start control service"];
            while(weakSelf.doCheck){
                [weakSelf logToMainThread:@"control thread checking"];
                // TODO wait for tcp connect
                int result = wait_for_tcpconnect(self.cfg.xvncHost, self.cfg.xvncXDisplayPort, 0, 200000);
                if (result != 0) {
                    [weakSelf logToMainThread:@"Service check error...."];
                    if(weakSelf.initialCheck){
                        [weakSelf logToMainThread:@"Not running process: allowStart"];
                        [weakSelf notificateServiceChanged:@"allowStart"];
                    }
                } else {
                    if(weakSelf.initialCheck){
                         [weakSelf logToMainThread:@"Running process: reestart required"];
                        [weakSelf notificateServiceChanged:@"stopBeforeStart"];
                    } else {
                        if([weakSelf getSrvStatus] == SRV_STARTED_PENDING_CHECK){
                            [weakSelf setServiceStatus:SRV_STARTED];
                            [weakSelf notificateServiceChanged:@"QVDXVNCServiceStarted"];
                            [weakSelf stopControl];
                        } else{
                            [weakSelf logToMainThread:@"Service check success... no stopControl"];
                        }
                    }
                }
                // TODO change sleep time to global
                [NSThread sleepForTimeInterval:.2f];
            }
        });
    }
    
}


-(void)stopService{
    NSLog(@"[QVDXvncService]->[stopService]");
    if([self getSrvStatus] == SRV_STARTED){
         NSLog(@"[QVDXvncService]->[stopService] dix_main_end()");
        dix_main_end();
    }
}

#pragma mark - Parameters configuration

-(void)generateParameters{
    if ( [ [self getFontPath] length ] >= MAXPATH ||
        [ [self getGeometry] length ] >= MAXPATH ||
        [ [self getPasswordArgPath] length ] >= MAXPATH) {
        NSLog(@"[CRITICAL ERROR] Exceeded expected maximum fontpath/geometry/password chars. Aborting");
        abort();
    }
    strncpy(fontpathchr, [[self getFontPath] UTF8String], MAXPATH);
    strncpy(geometrychr, [[self getGeometry] UTF8String], MAXPATH);
    strncpy(passwdargchr, [[self getPasswordArgPath] UTF8String], MAXPATH);
    strncpy(rfbport, [[self getRfbPort] UTF8String], MAXPATH);
}

- (NSString *) getBasePath {
    if(!self.basePath){
        self.basePath = [[NSBundle mainBundle] bundlePath];
    }
    return self.basePath;
}


- (NSString *) getFontPath {
    if(!self.fontPath){
        NSString* fontpathbase = [NSString stringWithFormat:@"%@/Library/files/usr/share/fonts",[self getBasePath]];
        self.fontPath = [NSString
                         stringWithFormat:@"%@/misc,%@/100dpi,%@/75dpi,%@/Speedo,%@/Type1",
                         fontpathbase, fontpathbase, fontpathbase, fontpathbase, fontpathbase];
    }
    return  self.fontPath;
}

- (NSString *) getGeometry {
    CGFloat currentWidth = MAX([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
    CGFloat currentHeight = MIN([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height) - NOVNC_TOP_FRAME_HEIGHT;
    return [NSString stringWithFormat:@"%dx%d", (int)currentWidth, (int)currentHeight];
}

- (NSString *) getPasswordPath {
    if(!self.passwordPath){
        self.passwordPath  = [NSString stringWithFormat:@"%@/Library/files/etc/vncpasswd",
                              [self getBasePath]];
    }
    return self.passwordPath;
}

- (NSString *) getPasswordArgPath {
    if(!self.passwordArgPath){
        self.passwordArgPath = [NSString stringWithFormat:@"-PasswordFile=%@",
                                [self getPasswordPath]];
    }
    return  self.passwordArgPath;
}

- (NSString *) getRfbPort {
    if(!self.rfbPort){
        self.rfbPort  = [NSString stringWithFormat:@"%d",
                              self.cfg.xvncVncPort];
    }
    return self.rfbPort;
}

@end
