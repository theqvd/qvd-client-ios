//
//  LoginViewController.m
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
//  Created by Oscar Costoya Vidal on 6/4/15.
//

#import "LoginViewController.h"
#import "QVDProxyService.h"
#import "QVDXvncService.h"
#import "QVDVmVO.h"
#include "tcpconnect.h"
#import "QVDClientWrapper.h"
#import "VncViewController.h"
#import "VmListViewController.h"
#import "ConnectionVO.h"
#import "KVNProgress.h"
#import "A0SimpleKeychain.h"
#import "CustomTextField.h"
#import "Reachability.h"


@interface LoginViewController ()

@property (strong,nonatomic) Reachability *inetCheck;
@property (assign,nonatomic) BOOL connectionAvailable;

@end

@implementation LoginViewController

-(id)init{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self = [self initWithNibName:@"LoginViewController_iPhone" bundle:nil];
    } else {
        self = [self initWithNibName:@"LoginViewController_iPad" bundle:nil];
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self doCheckInetConnection];
    self.connectionAvailable = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237./255. green:129./255. blue:9./255. alpha:1.];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"common.titleGeneric",@"The QVD");
    self.versionLabel.text = [NSString stringWithFormat:NSLocalizedString(@"messages.compilationInfo",@"Versión"),[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
    
    [self.txtHost setPlaceholder:NSLocalizedString(@"component.txtHost", @"Host")];
    [self.txtLogin setPlaceholder:NSLocalizedString(@"component.txtUser", @"User")];
    [self.txtPassword setPlaceholder:NSLocalizedString(@"component.txtPassword", @"Password")];
    [self.btLogin setTitle:NSLocalizedString(@"component.btLogin", @"Login") forState:UIControlStateNormal];
    [self.lblSaveCredentials setText:@"Pruebas"];
    [self.lblSaveCredentials setText:NSLocalizedString(@"component.lblRemember", @"Remember credentials")];
    
    [self.lblTeadDownConnection setText:NSLocalizedString(@"messages.tearDown", @"Tear down message")];
}

- (IBAction)doLogin:(id)sender {
    [self doCheckInetConnection];
    BOOL allowLogin = [[QVDClientWrapper sharedManager] loginAllowed];
    if([self validateForm] && allowLogin){
        if(self.connectionAvailable){
        NSString *auxLogin = [self.txtLogin.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *auxPassword = [self.txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *auxHost = [self.txtHost.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        ConnectionVO *auxConnection = nil;
        if(![auxHost isEqualToString:@""] || ![auxLogin isEqualToString:@""] || ![auxPassword isEqualToString:@""]){
            auxConnection = [ConnectionVO initWithUser:auxLogin andPassword:auxPassword andHost:auxHost];
        }
        VmListViewController *vmList = [[VmListViewController alloc] initWithConnection:auxConnection saveCredentials:self.switchRemember.isOn];
        [self.navigationController pushViewController:vmList animated:YES];
        } else {
            
            
            
            
            
            
            UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"common.error",@"Error") message:NSLocalizedString(@"messages.error.connectionNotAvailable",@"La conexión no está disponible") delegate:nil cancelButtonTitle:NSLocalizedString(@"common.ok",@"Aceptar") otherButtonTitles:nil];
            [anAlert show];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkConnectionStatus)
                                                 name:@"QVD_ALLOW_CONNECT"
                                               object:nil];
    
    [self.gaugeView setHidden:[[QVDClientWrapper sharedManager] loginAllowed]];
    [self.btLogin setEnabled:[[QVDClientWrapper sharedManager] loginAllowed]];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)checkConnectionStatus{
    [self.gaugeView setHidden:[[QVDClientWrapper sharedManager] loginAllowed]];
    [self.btLogin setEnabled:[[QVDClientWrapper sharedManager] loginAllowed]];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self retreiveUserInfo];
}

-(void)retreiveUserInfo{

    if([[A0SimpleKeychain keychain] hasValueForKey:@"qvd-user"]){

        [self.txtLogin setText:[[A0SimpleKeychain keychain] stringForKey:@"qvd-user"]];
        [self.txtPassword setText:[[A0SimpleKeychain keychain] stringForKey:@"qvd-pwd"]];
        [self.txtHost setText:[[A0SimpleKeychain keychain] stringForKey:@"qvd-host"]];
        [self.switchRemember setOn:YES];
    } else {
        [self.switchRemember setOn:NO];
        [self.txtHost setText:@""];
        [self.txtPassword setText:@""];
        [self.txtHost setText:@""];

    }
}

- (BOOL)validateForm {

    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];

    BOOL result = YES;

    if (!(self.txtHost.text.length >= 1)){
        self.txtHost.textColor = [UIColor redColor];
        result = NO;
    } else if (!(self.txtPassword.text.length >= 1)){
        self.txtPassword.textColor = [UIColor redColor];
        result = NO;
    } else if (![emailPredicate evaluateWithObject:self.txtLogin.text]){
        self.txtLogin.textColor = [UIColor redColor];
        result = NO;
    }
    return result;
}

-(void)doCheckInetConnection{
     self.inetCheck = [Reachability reachabilityForInternetConnection];
    [self.inetCheck startNotifier];
    [self updateInterfaceWithReachability:self.inetCheck];
}

-(void)updateInterfaceWithReachability:(Reachability *)reachability{

    self.connectionAvailable = NO;

    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    BOOL connectionRequired = [reachability connectionRequired];

    switch (netStatus)
    {
        case NotReachable:        {
            NSLog(@"NetworkCheck ===> Access Not Available");
            self.connectionAvailable = NO;
            connectionRequired = NO;
            break;
        }

        case ReachableViaWWAN:        {
            self.connectionAvailable = YES;
            NSLog(@"NetworkCheck ===> Reachable WWAN");
            break;
        }
        case ReachableViaWiFi:
        {
            self.connectionAvailable = YES;
            NSLog(@"NetworkCheck ===> Reachable WiFi");
            break;
        }
    }

    if (connectionRequired)
    {
        self.connectionAvailable = NO;
        //No hay conexión disponible

    }
}


@end
