//
//  VmListViewController.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 13/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "VmListViewController.h"
#import "QVDClientWrapper.h"
#import "KVNProgress.h"
#import "KVNProgressConfiguration.h"
#import "VmMachineCollectionViewCell.h"
#import "QVDVmVO.h"
#import "VncViewController.h"


@interface VmListViewController ()
@property (assign,nonatomic) BOOL loginRequired;
@property (strong,nonatomic) ConnectionVO *connection;
@property (strong,nonatomic) NSArray *vmList;

@end

@implementation VmListViewController

-(id)initWithConnection:(ConnectionVO *) aConnection{
    self = [self initWithNibName:nil bundle:nil];
    if(self){
        _vmList = nil;
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
    [KVNProgress showWithStatus:@"Conectando...."];
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


    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     QVDVmVO *anVm = [self.vmList objectAtIndex:[indexPath row]];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    // done in the vncViewController
    //[[QVDClientWrapper sharedManager] connectToVm:[anVm id]];

    VncViewController *vnc = [[VncViewController alloc] initWithVm:anVm];
    [self.navigationController pushViewController:vnc animated:YES];

}

- (void) qvdError:(NSString *)aMessage{
    [KVNProgress showErrorWithStatus:aMessage completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}



@end
