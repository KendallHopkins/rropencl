//
//  RRCLException.h
//  RROpenCL
//
//  Created by Kendall Hopkins on 2/18/11.
//  Copyright 2011 SoftwareElves. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenCL/OpenCL.h>

@interface RRCLException : NSObject
{
	cl_int errorCode;
}

- (RRCLException *)initWithErrorCode:(cl_int)errorCode_;
+ (void)raiseWithErrorCode:(cl_int)errorCode_;

@end
