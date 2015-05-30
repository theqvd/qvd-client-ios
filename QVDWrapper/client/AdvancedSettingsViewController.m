//
//  VncViewController.h
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

@interface AdvancedSettingsViewController ()

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
    
    [self.contentScroll setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 523.)];
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
    int auxWith=[[self.txtPort text] intValue];
    int auxHeight=[[self.txtPort text] intValue];

    if(auxPort == 0){
        [self.connectionConfiguration setQvdDefaultPort:auxPort];
    } else {
        [self.connectionConfiguration setQvdDefaultPort:QVD_DEFAULT_PORT];
    }
    if(auxWith == 0){
        [self.connectionConfiguration setQvdDefaultWidth:auxWith];
    } else {
         [self.connectionConfiguration setQvdDefaultWidth:[[UIScreen mainScreen] bounds].size.width];
    }
    if(auxHeight == 0){
        [self.connectionConfiguration setQvdDefaultHeight:auxHeight];
    } else {
        [self.connectionConfiguration setQvdDefaultHeight:[[UIScreen mainScreen] bounds].size.height];
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
    [self.connectionConfiguration setQvdDefaultLinkItem:selectedIndex];
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

    

}


@end
