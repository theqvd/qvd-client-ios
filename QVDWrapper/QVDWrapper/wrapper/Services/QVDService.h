//
//  QVDService.h
//  QVDWrapper
//
//  Created by Oscar Costoya Vidal on 14/3/15.
//  Copyright (c) 2015 Qindel. All rights reserved.
//

typedef enum {
    SRV_STARTING,
    SRV_STARTED,
    SRV_STARTED_PENDING_CHECK,
    SRV_stopping,
    SRV_STOPPED,
    SRV_FAILED
} QVDServiceState;