//
//  CommonNavigationController.m
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

#import "CommonNavigationController.h"

@interface CommonNavigationController ()

@end

@implementation CommonNavigationController

-(BOOL)shouldAutorotate
{
    
    BOOL autorotate = [[self.viewControllers lastObject] shouldAutorotate];
    if([self.viewControllers count] > 1){
        return autorotate;
    } else {
        return YES;
    }
        
}

-(NSUInteger)supportedInterfaceOrientations
{
    
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];

}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if([self.viewControllers count] > 1){
        return [[self.viewControllers lastObject] shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    } else {
        return YES;
    }
}



@end
