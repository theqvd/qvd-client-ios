//
//  VmListViewController.m
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
//  Created by Oscar Costoya Vidal on 13/4/15.
//

#import "VmListViewController.h"
#import "QVDClientWrapper.h"
#import "KVNProgress.h"
#import "KVNProgressConfiguration.h"
#import "VmMachineCollectionViewCell.h"
#import "QVDVmVO.h"
#import "VncViewController.h"
#import "A0SimpleKeychain.h"


@interface VmListViewController ()
@property (assign,nonatomic) BOOL loginRequired;
@property (strong,nonatomic) ConnectionVO *connection;
@property (strong,nonatomic) NSArray *vmList;

@end

@implementation VmListViewController

-(id)initWithConnection:(ConnectionVO *) aConnection saveCredentials:(BOOL)save{
    self = [self initWithNibName:nil bundle:nil];
    if(self){
        _vmList = nil;
        if(!save){
            [[A0SimpleKeychain keychain] clearAll];
        }
        if(aConnection){
            self.connection = aConnection;
        } else {
            // TODO init
            self.connection = [ConnectionVO initWithUser:@"appledevprogram@qindel.com" andPassword:@"applepass" andHost:@"demo.theqvd.com"];
        }
    }
    return self;
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self){
        _loginRequired = YES;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.cvVmMachines registerNib:[UINib nibWithNibName:@"VmMachineCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"VmMachineCollectionViewCell"];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237./255. green:129./255. blue:9./255. alpha:1.];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.title = @"List of VMs";

}

-(void)viewWillAppear:(BOOL)animated{
    if(self.loginRequired){

        [[QVDClientWrapper sharedManager] setStatusDelegate:self];
        [[QVDClientWrapper sharedManager] setCredentialsWitUser:[self.connection userLogin] password: [self.connection userPassword] host:[self.connection qvdHost]];
        [self showLoading];
        [[QVDClientWrapper sharedManager] listOfVms];
    }
}

-(void)showLoading{
    KVNProgressConfiguration *config = [KVNProgressConfiguration defaultConfiguration];
    config.lineWidth = 4.;
    config.backgroundTintColor = [UIColor colorWithRed:237./255. green:129./255. blue:9./255. alpha:1.];
    config.statusColor = [UIColor whiteColor];
    config.successColor = [UIColor whiteColor];
    config.errorColor = [UIColor whiteColor];
    config.circleStrokeForegroundColor = [UIColor whiteColor];
    config.fullScreen = YES;
    [KVNProgress setConfiguration:config];
    [KVNProgress showWithStatus:@"Connecting...."];
}

#pragma mark - Delegate

- (void) qvdProgressMessage:(NSString *) aMessage{
    [KVNProgress updateStatus:[NSString stringWithFormat:@"Progress: %@",aMessage]];

}

- (void) vmListRetrieved:(NSArray *) aVmList{
    self.loginRequired = NO;
    [[QVDClientWrapper sharedManager] setStatusDelegate:nil];
    [KVNProgress showSuccess];
    self.vmList = aVmList;
    [self.cvVmMachines reloadData];

    [[A0SimpleKeychain keychain] setString:self.connection.userLogin forKey:@"qvd-user"];
    [[A0SimpleKeychain keychain] setString:self.connection.userPassword forKey:@"qvd-pwd"];
    [[A0SimpleKeychain keychain] setString:self.connection.qvdHost forKey:@"qvd-host"];

}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.vmList){
        return [self.vmList count];
    } else {
      return 0;
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    QVDVmVO *anVm = [self.vmList objectAtIndex:[indexPath row]];

    VmMachineCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VmMachineCollectionViewCell" forIndexPath:indexPath];
    [[cell vmName] setText:[anVm name]];
    [[cell vmState] setText:[anVm state]];
    if(cell.selectedBackgroundView){
        [cell.selectedBackgroundView setBackgroundColor:[UIColor whiteColor]];
        [cell.backgroundView setBackgroundColor:[UIColor colorWithRed:224./255. green:224./255. blue:224./255. alpha:1.]];
    } else {
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 250., 150.)];
        [cell.selectedBackgroundView setBackgroundColor:[UIColor whiteColor]];
        [cell.backgroundView setBackgroundColor:[UIColor colorWithRed:224./255. green:224./255. blue:224./255. alpha:1.]];
    }


    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     QVDVmVO *anVm = [self.vmList objectAtIndex:[indexPath row]];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
     cell.contentView.backgroundColor = [UIColor whiteColor];
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];

    // done in the vncViewController
    //[[QVDClientWrapper sharedManager] connectToVm:[anVm id]];

    VncViewController *vnc = [[VncViewController alloc] initWithVm:anVm];
    [self.navigationController pushViewController:vnc animated:YES];

}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithRed:224./255. green:224./255. blue:224./255. alpha:1.];

}


- (void) qvdError:(NSString *)aMessage{
    [[A0SimpleKeychain keychain] clearAll];
    [KVNProgress showErrorWithStatus:aMessage completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

-(void)connectionFinished{

}


@end
