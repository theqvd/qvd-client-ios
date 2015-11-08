//
//  AdvancedSettingsViewController.h
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
//  Created by Oscar Costoya Vidal on 29/5/15.
//
#import "AdvancedSettingsViewController.h"
#import "ActionSheetStringPicker.h"
#import "PureLayout.h"
#import <Foundation/Foundation.h>

@interface AdvancedSettingsViewController ()

@property (strong,nonatomic) NSMutableDictionary *pemItems;
@property (strong,nonatomic) NSMutableArray *pemItemsKeys;
@property (strong,nonatomic) NSString *pemPath;

@property (strong,nonatomic) NSMutableDictionary *keyItems;
@property (strong,nonatomic) NSMutableArray *keyItemsKeys;
@property (strong,nonatomic) NSString *keyPath;


@end

@implementation AdvancedSettingsViewController

-(id)initViewWithConfig:(ConnectionVO *)aConfig{
    self = [super initWithNibName:@"AdvancedSettingsViewController_iPhone" bundle:nil];
    if(self){
        _connectionConfiguration = aConfig;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237./255. green:129./255. blue:9./255. alpha:1.];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = NSLocalizedString(@"common.titleAdvancedSettings",@"Advanced settings");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"common.cancel", @"") style:UIBarButtonItemStyleDone target:self action:@selector(dismissVC)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"common.ok", @"") style:UIBarButtonItemStyleDone target:self action:@selector(updateConfig)];
    
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
         [self.contentScroll setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 717.)];
         [self.containerWith autoRemove];
         self.containerWith = [self.formContainer autoSetDimension:ALDimensionWidth toSize:[[UIScreen mainScreen] bounds].size.width];
         [self.contentScroll layoutIfNeeded];
     } else {
         [self.contentScroll setContentSize:CGSizeMake(320., 717)];
     }
    [self localizeComponents];
    [self populateConfig];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)populateConfig{
    [self.txtUser setText:[self.connectionConfiguration qvdDefaultLogin]];
    [self.txtPassword setText:[self.connectionConfiguration qvdDefaultPass]];
    [self.txtHost setText:[self.connectionConfiguration qvdDefaultHost]];
    [self.txtPort setText:[NSString stringWithFormat:@"%d", [self.connectionConfiguration qvdDefaultPort]]];
    [self.txtWith setText:[NSString stringWithFormat:@"%d", [self.connectionConfiguration qvdDefaultWidth]]
];
    [self.txtHeight setText:[NSString stringWithFormat:@"%d", [self.connectionConfiguration qvdDefaultHeight]]];
    [self.switchDebug setOn:[self.connectionConfiguration qvdDefaultDebug]];
    [self.switchFullScreen setOn:[self.connectionConfiguration qvdDefaultFullScreen]];

    if([self.connectionConfiguration qvdDefaultLinkItem] == 0){
        [self.txtLinkSelected setText:@"Local"];
    } else if([self.connectionConfiguration qvdDefaultLinkItem] == 1){
        [self.txtLinkSelected setText:@"ADSL"];
    }else if([self.connectionConfiguration qvdDefaultLinkItem] == 2){
        [self.txtLinkSelected setText:@"Modem"];
    }
    
    [self.switchCertificates setOn:[self.connectionConfiguration qvdClientCertificates]];
    [self enableCerts:[self.connectionConfiguration qvdClientCertificates]];
    if([self.connectionConfiguration qvdClientCertificates]){
        if([self.connectionConfiguration qvdX509Cert]){
            [self.txt509Cert setText:[[self.connectionConfiguration qvdX509Cert] lastPathComponent]];
            self.pemPath = [self.connectionConfiguration qvdX509Cert];
        } else {
            [self.txt509Cert setText:@""];
            self.pemPath = @"";
        }
        if([self.connectionConfiguration qvdX509Cert]){
            [self.txt509Key setText:[[self.connectionConfiguration qvdX509Key]  lastPathComponent]];
            self.keyPath = [self.connectionConfiguration qvdX509Key];
        } else {
            [self.txt509Key setText:@""];
            self.keyPath = @"";
        }

    }
    
    [self.switchDebug setOn:[self.connectionConfiguration qvdDefaultDebug]];
    
    
    
}


-(void)updateConfig{
    if(self.configDelegate){
        [self updateConfiguration];
        [self.configDelegate configurationUpdated:self.connectionConfiguration];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)updateConfiguration{
    [self.connectionConfiguration setQvdDefaultLogin:[self.txtUser text]];
    [self.connectionConfiguration setQvdDefaultPass:[self.txtPassword text]];
    [self.connectionConfiguration setQvdDefaultHost:[self.txtHost text]];
    
    int auxPort =[[self.txtPort text] intValue];
    int auxWith=[[self.txtWith text] intValue];
    int auxHeight=[[self.txtHeight text] intValue];

    if(auxPort == 0){
        [self.connectionConfiguration setQvdDefaultPort:auxPort];
    } else {
        [self.connectionConfiguration setQvdDefaultPort:QVD_DEFAULT_PORT];
    }
    if(auxWith != 0){
        [self.connectionConfiguration setQvdDefaultWidth:auxWith];
    } else {
        [self.connectionConfiguration setQvdDefaultWidth:MAX([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
    }
    if(auxHeight != 0){
        [self.connectionConfiguration setQvdDefaultHeight:auxHeight];
    } else {
        [self.connectionConfiguration setQvdDefaultHeight:MIN([[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
    }
    
    [self.connectionConfiguration setQvdDefaultDebug:[self.switchDebug isOn]];
    [self.connectionConfiguration setQvdDefaultFullScreen:[self.switchFullScreen isOn]];
    
}

-(void)dismissVC{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)performLinkSelection:(id)sender {
    [self showLinkPicker];
}

-(void)showLinkPicker{
    [ActionSheetStringPicker showPickerWithTitle:@"Link"
                                            rows:@[@"Local",@"ADSL",@"Modem"]
                                initialSelection:[self.connectionConfiguration qvdDefaultLinkItem]
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self updateLink:selectedIndex];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     }
                                          origin:self.view];
}

-(void)updateLink:(NSInteger)selectedIndex{
    [self.connectionConfiguration setQvdDefaultLinkItem:(int)selectedIndex];
    if(selectedIndex == 0){
        [self.txtLinkSelected setText:@"Local"];
    } else if(selectedIndex == 1){
        [self.txtLinkSelected setText:@"ADSL"];
    }else if(selectedIndex == 2){
        [self.txtLinkSelected setText:@"Modem"];
    }
    
}

-(void)localizeComponents{
    
    
    [self.txtGroupAccount setText:NSLocalizedString(@"group.account", @"")];
    [self.txtGroupNetwork setText:NSLocalizedString(@"group.network", @"")];
    [self.txtGroupGeometry setText:NSLocalizedString(@"group.geometry", @"")];
    [self.txtGroupDebug setText:NSLocalizedString(@"group.debug", @"")];
    [self.txtTitleUser setText:NSLocalizedString(@"component.txtUser", @"")];
    [self.txtTitlePassword setText:NSLocalizedString(@"component.txtPassword", @"")];
    [self.txtTitleHost setText:NSLocalizedString(@"component.txtHost", @"")];
    [self.txtTitlePort setText:NSLocalizedString(@"component.txtPort", @"")];
    [self.txtTitleLink setText:NSLocalizedString(@"component.txtLink", @"")];
    [self.txtTitleWith setText:NSLocalizedString(@"component.txtWith", @"")];
    [self.txtTitleHeight setText:NSLocalizedString(@"component.txtHeight", @"")];
    [self.txtTitleFullScreen setText:NSLocalizedString(@"component.txtFullScreen", @"")];
    [self.txtTitleDebug setText:NSLocalizedString(@"component.txtDebug", @"")];
    
    [self.txtUser setPlaceholder:NSLocalizedString(@"placeholder.txtUser", @"")];
    [self.txtPassword setPlaceholder:NSLocalizedString(@"placeholder.txtPassword", @"")];
    [self.txtHost setPlaceholder:NSLocalizedString(@"placeholder.txtHost", @"")];
    [self.txtPort setPlaceholder:NSLocalizedString(@"placeholder.txtPort", @"")];
    
    [self.txtGroupCertificates setText:NSLocalizedString(@"component.txtGroupCertificates", @"CERTIFICATES")];
    [self.txtTitleClientCertificate setText:NSLocalizedString(@"component.txtTitleClientCertificate", @"Client certificates")];
    [self.titleX509Cert setText:NSLocalizedString(@"component.titleX509Cert", @"X509 Cert")];
    [self.titleX509Key setText:NSLocalizedString(@"component.titleX509Key", @"X509 Key")];
    [self.txtHelp setText:NSLocalizedString(@"component.txtHelp", @"¿ Como importar los certificados ?")];
    

    

}

- (IBAction)clientCertificatesChange:(id)sender {
    [self enableCerts:[self.switchCertificates isOn]];
}

-(void)enableCerts:(BOOL)enable{
    self.bt509Cert.enabled = enable;
    self.bt509Key.enabled = enable;
    self.connectionConfiguration.qvdClientCertificates = enable;
    if(!enable){
        self.pemPath = @"";
        self.keyPath = @"";
        self.txt509Cert.text = @"- - -";
        self.txt509Key.text = @"- - -";
        self.connectionConfiguration.qvdX509Cert = @"";
        self.connectionConfiguration.qvdX509Key = @"";
        
    } else {
        self.pemPath = @"";
        self.keyPath = @"";
        self.txt509Cert.text = @"";
        self.txt509Key.text = @"";
    }
}

- (IBAction)changeDebugMode:(id)sender {
    [self.connectionConfiguration setQvdDefaultDebug:[self.switchDebug isOn]];
}

- (IBAction)listX509Cert:(id)sender {

    NSArray *aux = [self getFilesByExtension:@"pem"];
    self.pemItemsKeys = [[NSMutableArray alloc] init];
    self.pemItems = [[NSMutableDictionary alloc] init];
    for(NSString *path in aux){
        [self.pemItemsKeys addObject:[path lastPathComponent]];
        [self.pemItems setObject:path forKey:[path lastPathComponent]];
    }
    
    if([aux count] > 0){
    
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"component.titleX509Cert", @"X509 Cert")
                                            rows:self.pemItemsKeys
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self updateX509Cert:selectedValue];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     }
                                          origin:self.view];
    } else {
        UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"messages.noFiles", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"common.ok", @"") otherButtonTitles:nil];
        [anAlert show];
    }
}

-(void)updateX509Cert:(NSString *)aKey{
    if(aKey){
        NSString *completePath = [self.pemItems objectForKey:aKey];
        if(completePath){
            [self.txt509Cert setText:[completePath lastPathComponent]];
            self.pemPath = completePath;
            self.connectionConfiguration.qvdX509Cert = completePath;
        } else {
            [self.txt509Cert setText:@"- - -"];
            self.connectionConfiguration.qvdX509Cert = @"";
        }
    } else {
        [self.txt509Cert setText:@"- - -"];
        self.connectionConfiguration.qvdX509Cert = @"";
    }
}

- (IBAction)listX509Key:(id)sender {
    NSArray *aux = [self getFilesByExtension:@"key"];
    self.keyItemsKeys = [[NSMutableArray alloc] init];
    self.keyItems = [[NSMutableDictionary alloc] init];
    for(NSString *path in aux){
        [self.keyItemsKeys addObject:[path lastPathComponent]];
        [self.keyItems setObject:path forKey:[path lastPathComponent]];
    }
        if([aux count] > 0){
    [ActionSheetStringPicker showPickerWithTitle:NSLocalizedString(@"component.titleX509Key", @"X509 Key")
                                            rows:self.keyItemsKeys
                                initialSelection:0
                                       doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                                           [self updateX509Key:selectedValue];
                                       }
                                     cancelBlock:^(ActionSheetStringPicker *picker) {
                                         
                                     }
                                          origin:self.view];
        } else {
            UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"messages.noFiles", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"common.ok", @"") otherButtonTitles:nil];
            [anAlert show];
        }
    
}

-(void)updateX509Key:(NSString *)aKey{
    if(aKey){
        NSString *completePath = [self.keyItems objectForKey:aKey];
        if(completePath){
            [self.txt509Key setText:[completePath lastPathComponent]];
            self.keyPath = completePath;
            self.connectionConfiguration.qvdX509Key = completePath;;
        } else {
            [self.txt509Key setText:@"- - -"];
            self.connectionConfiguration.qvdX509Key = @"";
        }
    } else {
        [self.txt509Key setText:@"- - -"];
        self.connectionConfiguration.qvdX509Key = @"";
    }
}

-(NSArray *)getFilesByExtension:(NSString *)anExtension{
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    
    
    
    bundleURL = [NSURL fileURLWithPath:documentsPath];
    
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:bundleURL
                                          includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                             options:NSDirectoryEnumerationSkipsHiddenFiles
                                                        errorHandler:^BOOL(NSURL *url, NSError *error)
                                         {
                                             if (error) {
                                                 NSLog(@"[Error] %@ (%@)", error, url);
                                                 return NO;
                                             }
                                             
                                             return YES;
                                         }];
    
    for (NSURL *fileURL in enumerator) {
        NSString *filename;
        [fileURL getResourceValue:&filename forKey:NSURLNameKey error:nil];
        
        NSNumber *isDirectory;
        [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        
        // Skip directories with '_' prefix, for example
        if ([filename hasPrefix:@"_"] && [isDirectory boolValue]) {
            [enumerator skipDescendants];
            continue;
        }
        
        if (![isDirectory boolValue]) {
            if([[anExtension lowercaseString] isEqualToString:[[[fileURL path] pathExtension] lowercaseString]]){
                [itemsArray addObject:[fileURL path]];
                NSLog(@"Find item at path: %@",[fileURL path]);
            }
        }
    }
    return itemsArray;
}

- (IBAction)showImportHelp:(id)sender {
   UIAlertView *anAlert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"messages.importCertificatesInstructions", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"common.ok", @"") otherButtonTitles:nil];
    [anAlert show];
 
}


- (BOOL)shouldAutorotate {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return YES;
    } else {
        return NO;
    }
    
}


-(UIInterfaceOrientationMask)supportedInterfaceOrientations
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
        return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        if((toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) || (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)){
            return YES;
        }
        return NO;
    }
}

@end
