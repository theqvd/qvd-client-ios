//
//  CustomTextField.m
//  client
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
//  Created by Oscar Costoya on 8/5/15.
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
