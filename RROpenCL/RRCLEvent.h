//
//  RRCLEvent.h
//  RROpenCL
//
//  Created by Kendall Hopkins on 2/18/11.
//  Copyright 2011 SoftwareElves. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenCL/OpenCL.h>

@interface RRCLEvent : NSObject
{
	cl_event clEvent;
}

+ (void)waitForArrayToFinish:(NSArray *)eventArray;

- (id)initWithCLEvent:(cl_event)event_;

- (void)waitToFinish;

- (cl_event)clEvent;

@end
