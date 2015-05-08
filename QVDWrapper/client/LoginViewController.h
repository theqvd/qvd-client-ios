//
//  LoginViewController.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 6/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QVDClientWrapper.h"
#import "CustomTextField.h"

@interface LoginViewController : UIViewController<QVDStatusDelegate>

@property (weak, nonatomic) IBOutlet CustomTextField *txtHost;
@property (weak, nonatomic) IBOutlet CustomTextField *txtLogin;
@property (weak, nonatomic) IBOutlet UISwitch *switchRemember;
@property (weak, nonatomic) IBOutlet CustomTextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *btLogin;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end
