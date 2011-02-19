//
//  RRCLEvent.m
//  RROpenCL
//
//  Created by Kendall Hopkins on 2/18/11.
//  Copyright 2011 SoftwareElves. All rights reserved.
//

#import "RRCLEvent.h"

#import "RRCLException.h"

@implementation RRCLEvent

+ (void)waitForArrayToFinish:(NSArray *)eventArray
{
    NSUInteger eventArrayCount = [eventArray count];
    cl_event clEventArray[eventArrayCount];
    for( int i = 0; i < eventArrayCount; i++ ) {
        RRCLEvent * currentEvent = [eventArray objectAtIndex:i];
        clEventArray[i] = [currentEvent clEvent];
    }
    cl_int errorCode = clWaitForEvents((cl_uint)eventArrayCount, clEventArray);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
}

- (id)initWithCLEvent:(cl_event)event_
{
    self = [super init];
    if (self) {
        clEvent = event_;
    }
    
    return self;
}

- (void)waitToFinish
{
    cl_int errorCode = clWaitForEvents(1, &clEvent);
    if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
}

- (cl_event)clEvent
{
    return clEvent;
}

- (void)dealloc
{
	clReleaseEvent(clEvent);
	[super dealloc];
}

- (void)finalize
{
	clReleaseEvent(clEvent);
	[super finalize];
}

@end
