//
//  RRCLException.m
//  RROpenCL
//
//  Created by Kendall Hopkins on 2/18/11.
//  Copyright 2011 SoftwareElves. All rights reserved.
//

#import "RRCLException.h"

@implementation RRCLException

- (RRCLException *)initWithErrorCode:(cl_int)errorCode_
{
    self = [super init];
    if (self) {
        errorCode = errorCode_;
    }
    
    return self;
}

+ (void)raiseWithErrorCode:(cl_int)errorCode_
{
    @throw [[RRCLException alloc] initWithErrorCode:errorCode_];
}

@end
