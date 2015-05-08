//
//  QVDVmVO.h
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

#import <Foundation/Foundation.h>

@interface QVDVmVO : NSObject

@property (nonatomic) int id;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *state;
@property (nonatomic) int blocked;

-(id) initWithId: (int) aId andName:(const char *) aName andState: (const char *) aState andBlocked: (int) aBlocked;
-(NSString *)description;

@end
