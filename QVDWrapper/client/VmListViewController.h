//
//  VmListViewController.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 13/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConnectionVO.h"
#import "QVDClientWrapper.h"

@interface VmListViewController : UIViewController<QVDStatusDelegate,UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *cvVmMachines;
-(id)initWithConnection:(ConnectionVO *) aConnection saveCredentials:(BOOL)save;

@end
