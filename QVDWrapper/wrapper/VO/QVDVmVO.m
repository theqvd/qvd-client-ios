//
//  QVDVmVO.m
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
//  Created by Oscar Costoya Vidal on 4/4/15.
//

#import "QVDVmVO.h"

@implementation QVDVmVO

-(id) initWithId: (int) aId andName:(const char *) aName andState: (const char *) aState andBlocked: (int) aBlocked{
    self = [super init];
    if(self){

        _name = [[NSString alloc] initWithUTF8String:aName];
        _state= [[NSString alloc] initWithUTF8String:aState];
        _id= aId;
        _blocked = aBlocked;

    }
    return self;
}

-(NSString *)description {

    return [[NSString alloc] initWithFormat:@"%@(%d) - %@",self.name, self.id, self.state];

}

@end
