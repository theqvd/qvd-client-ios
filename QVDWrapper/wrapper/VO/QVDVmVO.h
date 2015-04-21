//
//  QVDVmVO.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 4/4/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
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
