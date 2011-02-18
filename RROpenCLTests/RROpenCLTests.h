//
//	RROpenCLTests.h
//	RROpenCLTests
//
//	Created by Kendall Hopkins on 2/17/11.
//	Copyright 2011 SoftwareElves. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "RROpenCL.h"

@interface RROpenCLTests : SenTestCase {
@private
	NSArray * devices;
	RRCLDevice * mainDevice;
	RRCLContext * context;
	RRCLCommandQueue * commandQueue;
}

@end
