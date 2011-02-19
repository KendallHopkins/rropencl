// RROpenCL RRCLCommandQueue.m
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

#import "RRCLCommandQueue.h"
#import "RRCLBuffer.h"
#import "RRCLKernel.h"
#import "RRCLContext.h"
#import "RRCLDevice.h"
#import "RRCLException.h"

@implementation RRCLCommandQueue

- (id)initWithContext:(RRCLContext *)aContext device:(RRCLDevice *)aDevice
{
	self = [super init];
	if (self) {
		cl_int errcode;
		clCommandQueue = clCreateCommandQueue([aContext clContext], [aDevice clDeviceId], 0, &errcode);
		if (CL_SUCCESS != errcode) {
			[self release];
			return nil;
		}
		device = [aDevice retain];
		context = [aContext retain];
	}
	return self;
}

//------------------------------------------------------------------------------
#pragma mark                                                                Info
//------------------------------------------------------------------------------

- (RRCLContext *)context
{
	return context;
}

- (RRCLDevice *)device
{
	return device;
}

- (NSData *)enqueueReadBuffer:(RRCLBuffer *)aBuffer blocking:(cl_bool)blocking
{
	return [self enqueueReadBuffer:aBuffer blocking:blocking offset:0 length:[aBuffer size]];
}

- (NSData *)enqueueReadBuffer:(RRCLBuffer *)aBuffer blocking:(cl_bool)blocking offset:(size_t)offset length:(size_t)cb
{
	NSMutableData *data = [NSMutableData dataWithLength:cb];
	cl_int errorCode = clEnqueueReadBuffer(clCommandQueue, [aBuffer clMem], blocking, offset, cb, [data mutableBytes], 0, NULL, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];

	return data;
}

- (void)enqueueWriteBuffer:(RRCLBuffer *)aBuffer blocking:(cl_bool)blocking offset:(size_t)offset data:(NSData *)data
{
	cl_int errorCode = clEnqueueWriteBuffer(clCommandQueue, [aBuffer clMem], blocking, offset, [data length], [data bytes], 0, NULL, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
}

- (void)enqueueNDRangeKernel:(RRCLKernel *)aKernel globalWorkSize:(size_t)globalWorkSize
{
	cl_int errorCode = clEnqueueNDRangeKernel(clCommandQueue, [aKernel clKernel], 1, NULL, &globalWorkSize, NULL, 0, NULL, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
}

- (void)enqueueNDRangeKernel:(RRCLKernel *)aKernel globalWorkSize:(size_t)globalWorkSize localWorkSize:(size_t)localWorkSize
{
	cl_int errorCode = clEnqueueNDRangeKernel(clCommandQueue, [aKernel clKernel], 1, NULL, &globalWorkSize, &localWorkSize, 0, NULL, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
}

- (void)flush
{
	cl_int errorCode = clFlush(clCommandQueue);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
}

- (void)finish
{
	cl_int errorCode = clFinish(clCommandQueue);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
}

- (void)dealloc
{
	clReleaseCommandQueue(clCommandQueue);
	[super dealloc];
}

- (void)finalize
{
	clReleaseCommandQueue(clCommandQueue);
	[super finalize];
}

@end
