//
//  VncViewController.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 6/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QVDVmVO.h"
#import "QVDClientWrapper.h"

@interface VncViewController : UIViewController<UIWebViewDelegate,QVDStatusDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *navegador;


-(id)initWithVm:(QVDVmVO *)anVm;

@end
