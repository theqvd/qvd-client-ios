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

#import <UIKit/UIKit.h>
#import "QVDConfig.h"
#import "ConnectionVO.h"

@protocol QVDConfigDelegate

@required
- (void) configurationUpdated:(ConnectionVO *) aNewConfiguration;

@end

@interface AdvancedSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *contentScroll;

@property (weak, nonatomic) IBOutlet UITextField *txtUser;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtHost;
@property (weak, nonatomic) IBOutlet UITextField *txtPort;
@property (weak, nonatomic) IBOutlet UITextField *txtWith;
@property (weak, nonatomic) IBOutlet UITextField *txtHeight;
@property (weak, nonatomic) IBOutlet UISwitch *switchFullScreen;
@property (weak, nonatomic) IBOutlet UISwitch *switchDebug;
@property (weak, nonatomic) IBOutlet UILabel *txtLinkSelected;

@property (weak, nonatomic) IBOutlet UILabel *txtGroupAccount;
@property (weak, nonatomic) IBOutlet UILabel *txtGroupNetwork;
@property (weak, nonatomic) IBOutlet UILabel *txtGroupGeometry;
@property (weak, nonatomic) IBOutlet UILabel *txtGroupDebug;
@property (weak, nonatomic) IBOutlet UILabel *txtTitleUser;
@property (weak, nonatomic) IBOutlet UILabel *txtTitlePassword;
@property (weak, nonatomic) IBOutlet UILabel *txtTitleHost;
@property (weak, nonatomic) IBOutlet UILabel *txtTitlePort;
@property (weak, nonatomic) IBOutlet UILabel *txtTitleLink;
@property (weak, nonatomic) IBOutlet UILabel *txtTitleWith;
@property (weak, nonatomic) IBOutlet UILabel *txtTitleHeight;
@property (weak, nonatomic) IBOutlet UILabel *txtTitleFullScreen;
@property (weak, nonatomic) IBOutlet UILabel *txtTitleDebug;



//Delegate
@property (strong,nonatomic) id<QVDConfigDelegate> configDelegate;

//Configuration
@property (strong,nonatomic) ConnectionVO *connectionConfiguration;

-(id)initViewWithConfig:(ConnectionVO *)aConfig;

@end
