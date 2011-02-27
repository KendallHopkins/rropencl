// RROpenCL RRCLKernel.m
//
// Copyright © 2009, Roy Ratcliffe, Lancaster, United Kingdom
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EITHER
// EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
//------------------------------------------------------------------------------

#import "RRCLKernel.h"
#import "RRCLBuffer.h"
#import "RRCLProgram.h"
#import "RRCLException.h"
#import "RRCLDevice.h"

@interface RRCLKernel ()

- (void)setArg:(NSUInteger)argIndex toValue:(const void *)value withSize:(size_t)size;

@end

@implementation RRCLKernel

- (id)initWithKernelName:(NSString *)kernelName inProgram:(RRCLProgram *)aProgram
{
	self = [super init];
	if (self)
	{
		cl_int errcode;
		clKernel = clCreateKernel([aProgram clProgram], [kernelName cStringUsingEncoding:NSASCIIStringEncoding], &errcode);
		if (CL_SUCCESS != errcode)
		{
			[self release];
			return nil;
		}
	}
	return self;
}

- (cl_kernel)clKernel
{
	return clKernel;
}

- (void)dealloc
{
	clReleaseKernel(clKernel);
	[super dealloc];
}

- (void)finalize
{
	clReleaseKernel(clKernel);
	[super finalize];
}

- (void)setArg:(NSUInteger)argIndex toValue:(const void *)value withSize:(size_t)size
{
	cl_int errorCode = clSetKernelArg(clKernel, (cl_uint)argIndex, size, value);	   
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
}

- (void)setArg:(NSUInteger)argIndex toData:(NSData *)aData
{
	[self setArg:argIndex toValue:[aData bytes] withSize:[aData length]];
}

- (void)setArg:(NSUInteger)argIndex toBuffer:(RRCLBuffer *)aBuffer
{
	cl_mem mem = [aBuffer clMem];
	[self setArg:argIndex toValue:&mem withSize:sizeof(mem)];
}

- (void)setArg:(NSUInteger)argIndex toShareWithSize:(NSNumber *)shareSize
{
	[self setArg:argIndex toValue:NULL withSize:(size_t)[shareSize unsignedIntValue]];
}

- (void)setArgArray:(NSArray *)argArray
{
	NSUInteger argArrayCount = [argArray count];
	for( int i = 0; i < argArrayCount; i++ ) {
		id argObject = [argArray objectAtIndex:i];
		Class argObjectClass = [argObject class];
		if( [argObjectClass isSubclassOfClass:[RRCLBuffer class]] ) {
			[self setArg:i toBuffer:argObject];
		} else if( [argObjectClass isSubclassOfClass:[NSData class]] ) {
			[self setArg:i toData:argObject];
		} else {
			[NSException raise:NSInvalidArgumentException format:@"bad class name: %@", argObjectClass];
		}
	}
}

//------------------------------------------------------------------------------
#pragma mark																Info
//------------------------------------------------------------------------------

- (NSString *)name
{
	size_t size;
	cl_int errorCode;
	errorCode = clGetKernelInfo(clKernel, CL_KERNEL_FUNCTION_NAME, 0, NULL, &size);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
	
	char info[size];
	errorCode = clGetKernelInfo(clKernel, CL_KERNEL_FUNCTION_NAME, size, info, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
	
	return [NSString stringWithCString:info encoding:NSASCIIStringEncoding];
}

- (cl_uint)numberOfArgs
{
	cl_uint numberOfArgs;
	cl_int errorCode = clGetKernelInfo(clKernel, CL_KERNEL_NUM_ARGS, sizeof(numberOfArgs), &numberOfArgs, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
	
	return numberOfArgs;
}

//------------------------------------------------------------------------------
#pragma mark													 Work Group Info
//------------------------------------------------------------------------------

- (size_t)workGroupSizeForDevice:(RRCLDevice *)device
{
	size_t size;
	cl_int errorCode = clGetKernelWorkGroupInfo(clKernel, [device clDeviceId], CL_KERNEL_WORK_GROUP_SIZE, sizeof(size), &size, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
	
	return size;
}

@end
