//
//	RROpenCLTests.m
//	RROpenCLTests
//
//	Created by Kendall Hopkins on 2/17/11.
//	Copyright 2011 SoftwareElves. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RROpenCLTests.h"

@interface RROpenCLTests ()

- (void)_testAddKernel:(RRCLKernel *)addKernel;

@end

@implementation RROpenCLTests

- (void)setUp
{
	[super setUp];
	
	devices = [[RRCLDevice devicesForPlatform:NULL type:CL_DEVICE_TYPE_DEFAULT] retain];
	STAssertTrue( [devices count] > 0, @"must have at least one opencl device" );
	mainDevice = [devices objectAtIndex:0];
	
	context = [[RRCLContext alloc] initWithDevices:[NSArray arrayWithObject:mainDevice]];
	commandQueue = [[RRCLCommandQueue alloc] initWithContext:context device:mainDevice];
}

- (void)tearDown
{
	[commandQueue release];
	[context release];
	[devices release];
	
	[super tearDown];
}

- (void)testBuildSource
{
	NSError * error = nil;
	NSString * program_data = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"helloworld" ofType:@"cl"] encoding:NSASCIIStringEncoding error:&error];
	RRCLProgram * programFromSource = [[[RRCLProgram alloc] initWithSource:program_data inContext:context] autorelease];
	cl_int build_code = [programFromSource build];
	if( build_code ) {
		STFail(@"Fail to build helloworld.cl");
		return;
	}
	
	NSArray * binarys = [programFromSource binarys];
	RRCLProgram * programFromBinary = [[RRCLProgram alloc] initWithBinarys:binarys forDevices:[NSArray arrayWithObject:mainDevice] inContext:context];
	[programFromBinary build];
	RRCLKernel * addKernel = [programFromBinary kernelWithName:@"add"];
	[self _testAddKernel:addKernel];
}

- (void)testSimpleAddFromSource
{
	NSError * error = nil;
	NSString * program_data = [NSString stringWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"helloworld" ofType:@"cl"] encoding:NSASCIIStringEncoding error:&error];
	RRCLProgram * programFromSource = [[[RRCLProgram alloc] initWithSource:program_data inContext:context] autorelease];
	cl_int build_code = [programFromSource build];
	if( build_code ) {
		STFail(@"Fail to build helloworld.cl");
		return;
	}
	RRCLKernel * addKernel = [programFromSource kernelWithName:@"add"];
	[self _testAddKernel:addKernel];
}

- (void)testSimpleAddFromBinary
{
	NSArray * binarys = [NSArray arrayWithObject:[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"helloworld" ofType:nil]]];
	RRCLProgram * programFromBinary = [[[RRCLProgram alloc] initWithBinarys:binarys forDevices:[NSArray arrayWithObject:mainDevice] inContext:context] autorelease];
	cl_int build_code = [programFromBinary build];
	if( build_code ) {
		STFail(@"Fail to build helloworld.cl");
		return;
	}
	RRCLKernel * addKernel = [programFromBinary kernelWithName:@"add"];
	[self _testAddKernel:addKernel];
}

- (void)_testAddKernel:(RRCLKernel *)addKernel
{
	cl_int x = 30;
	cl_int y = 12;
	cl_int output;
	
	RRCLBuffer * outputBuffer = [[RRCLBuffer alloc] initWriteOnlyWithContext:context size:sizeof(cl_int)];
	[addKernel setArgArray:[NSArray arrayWithObjects:
							[NSData dataWithBytesNoCopy:&x length:sizeof(x) freeWhenDone:NO],
							[NSData dataWithBytesNoCopy:&y length:sizeof(y) freeWhenDone:NO],
							outputBuffer, nil]];
	[commandQueue enqueueNDRangeKernel:addKernel globalWorkSize:1];
	NSData * data = [commandQueue enqueueReadBuffer:outputBuffer blocking:CL_FALSE];
	[commandQueue finish];
	[outputBuffer release];
	output = *(cl_int * )[data bytes];
	STAssertTrue(output == 42, @"calculation was wrong: 42 != %d", output);
}

@end
