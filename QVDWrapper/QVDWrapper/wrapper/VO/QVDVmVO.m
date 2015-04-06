//
//  QVDVmVO.m
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 4/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
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
