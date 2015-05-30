//
//  CommonNavigationController.m
//  client
//
//  Created by Oscar Costoya Vidal on 26/5/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "CommonNavigationController.h"

@interface CommonNavigationController ()

@end

@implementation CommonNavigationController

-(BOOL)shouldAutorotate
{
    
    BOOL autorotate = [[self.viewControllers lastObject] shouldAutorotate];
    return autorotate;
        
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return [[self.viewControllers lastObject] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}



@end
