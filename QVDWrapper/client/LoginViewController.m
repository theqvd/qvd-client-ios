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
#import "AdvancedSettingsViewController.h"
#import "FixeViewController.h"
#import "CommonNavigationController.h"
#import "InfoViewController.h"


@interface LoginViewController ()

@property (strong,nonatomic) Reachability *inetCheck;
@property (assign,nonatomic) BOOL connectionAvailable;
@property (assign,nonatomic) BOOL updateFromPreferences;
@property (assign,nonatomic) BOOL ignoreWorkaround;

@property (strong,nonatomic) ConnectionVO *aSelectedConfig;

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
    self.updateFromPreferences = YES;
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
    [self.btAbout setTitle:NSLocalizedString(@"common.titleAbout", @"About...") forState:UIControlStateNormal];
    
    [self.lblTeadDownConnection setText:NSLocalizedString(@"messages.tearDown", @"Tear down message")];
    
    [self.btAdvancedSettings setTitle:NSLocalizedString(@"common.titleAdvancedSettings", @"") forState:UIControlStateNormal];
}

- (IBAction)doLogin:(id)sender {
    [self doCheckInetConnection];
    BOOL allowLogin = [[QVDClientWrapper sharedManager] loginAllowed];
    if([self validateForm] && allowLogin){
        if(!self.aSelectedConfig){
            self.aSelectedConfig = [QVDConfig configWithDefaults];
        }
        
        
        if(self.connectionAvailable){
        NSString *auxLogin = [self.txtLogin.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *auxPassword = [self.txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSString *auxHost = [self.txtHost.text stringByReplacingOccurrencesOfString:@" " withString:@""];
  
        
            
        [self.aSelectedConfig setQvdDefaultHost:auxHost];
        [self.aSelectedConfig setQvdDefaultPass:auxPassword];
        [self.aSelectedConfig setQvdDefaultLogin:auxLogin];
            
        VmListViewController *vmList = [[VmListViewController alloc] initWithConnection:self.aSelectedConfig saveCredentials:[self.switchRemember isOn]];
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
    [UIViewController attemptRotationToDeviceOrientation];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }
    
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
    if(self.updateFromPreferences){
        self.updateFromPreferences = NO;
        [self retreiveUserInfo];
    }
    [UIViewController attemptRotationToDeviceOrientation];
    
   /* if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSNumber *value = [NSNumber numberWithInt:UIDeviceOrientationPortrait];
        [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    }*/
}

-(void)retreiveUserInfo{

    if([[A0SimpleKeychain keychain] hasValueForKey:@"qvd-configuration"]){

        NSData *encodedObject =[[A0SimpleKeychain keychain] dataForKey:@"qvd-configuration"];
        
         self.aSelectedConfig =[NSKeyedUnarchiver unarchiveObjectWithData:encodedObject];
        
        [self.txtLogin setText:[self.aSelectedConfig qvdDefaultLogin]];
        [self.txtPassword setText:[self.aSelectedConfig qvdDefaultPass]];
        [self.txtHost setText:[self.aSelectedConfig qvdDefaultHost]];
        [self.switchRemember setOn:YES];
    } else {
        [[A0SimpleKeychain keychain] clearAll];
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
    } else if (!(self.txtLogin.text.length >= 1)){
        self.txtLogin.textColor = [UIColor redColor];
        result = NO;
    }
    
    /*else if (![emailPredicate evaluateWithObject:self.txtLogin.text]){
        self.txtLogin.textColor = [UIColor redColor];
        result = NO;
    }*/
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


- (BOOL)shouldAutorotate {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return YES;
    } else {
        return NO;
    }
    
}


-(NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait;
    } else {
        return UIInterfaceOrientationMaskLandscape;
    }
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationPortrait;
    } else {
        return (UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight);
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return YES;
    } else {
        if((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)){
            return YES;
        }
        return NO;
    }
}

- (IBAction)showAdvancedSettings:(id)sender {
    self.ignoreWorkaround = YES;
    if(!self.aSelectedConfig){
      self.aSelectedConfig = [QVDConfig configWithDefaults];
    }
    
    NSString *auxLogin = [self.txtLogin.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *auxPassword = [self.txtPassword.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *auxHost = [self.txtHost.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self.aSelectedConfig setQvdDefaultLogin:auxLogin];
    [self.aSelectedConfig setQvdDefaultPass:auxPassword];
    [self.aSelectedConfig setQvdDefaultHost:auxHost];
    
    AdvancedSettingsViewController *asvc = [[AdvancedSettingsViewController alloc] initViewWithConfig:self.aSelectedConfig];
    asvc.configDelegate = self;
    
    CommonNavigationController *aNav = [[CommonNavigationController alloc] initWithRootViewController:asvc];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
    
    aNav.modalPresentationStyle = UIModalPresentationPopover;
    aNav.popoverPresentationController.sourceView =self.pophoverView;
    }
    
    [self presentViewController:aNav animated:YES completion:nil];
    
}

- (void) configurationUpdated:(ConnectionVO *) aNewConfiguration{
    self.aSelectedConfig = aNewConfiguration;
    [self.txtHost setText:[self.aSelectedConfig qvdDefaultHost]];
    [self.txtLogin setText:[self.aSelectedConfig qvdDefaultLogin]];
    [self.txtPassword setText:[self.aSelectedConfig qvdDefaultPass]];
    
}

- (IBAction)showAbout:(id)sender {
    InfoViewController *about = [[InfoViewController alloc] initWithNibName:nil bundle:nil];
    CommonNavigationController *aNav = [[CommonNavigationController alloc] initWithRootViewController:about];
    if ([[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPhone) {
        aNav.modalPresentationStyle = UIModalPresentationFormSheet;
            [self presentViewController:aNav animated:YES completion:nil];
        aNav.view.superview.frame = CGRectMake(0, 0, 200, 200);//it's important to do this after
        aNav.view.superview.center = self.view.center;
            //about.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal; //transition shouldn't matter
    } else {
            [self presentViewController:aNav animated:YES completion:nil];
    }
    

    
}



@end
