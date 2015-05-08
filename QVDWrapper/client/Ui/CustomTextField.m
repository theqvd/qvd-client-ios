//
//  CustomTextField.m
//  client
//
//  Created by Oscar Costoya on 8/5/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

#import "CustomTextField.h"

@implementation CustomTextField

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        self.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,10,38.)];
        self.leftViewMode=UITextFieldViewModeAlways;
        
        self.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,10,38.)];
        self.rightViewMode=UITextFieldViewModeAlways;
    }
    
    return self;
    
}

@end
