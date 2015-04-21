//
//  VmMachineCollectionViewCell.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 13/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VmMachineCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *vmName;
@property (weak, nonatomic) IBOutlet UILabel *vmState;

@end
