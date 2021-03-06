// RROpenCL RRCLCommandQueue.h
//
// Copyright © 2009, Roy Ratcliffe, Pioneering Software, United Kingdom
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

#import <Foundation/Foundation.h>

#import <OpenCL/OpenCL.h>

@class RRCLBuffer;
@class RRCLKernel;
@class RRCLContext;
@class RRCLDevice;

@interface RRCLCommandQueue : NSObject
{
	cl_command_queue clCommandQueue;
	RRCLContext * context;
	RRCLDevice * device;
}

- (id)initWithContext:(RRCLContext *)aContext device:(RRCLDevice *)aDevice;

- (RRCLContext *)context;
- (RRCLDevice *)device;

- (NSData *)enqueueReadBuffer:(RRCLBuffer *)aBuffer blocking:(cl_bool)blocking;
- (NSData *)enqueueReadBuffer:(RRCLBuffer *)aBuffer blocking:(cl_bool)blocking offset:(size_t)offset length:(size_t)cb;

	// Reads from a buffer object to host memory. The buffer and command queue
	// must belong to the same context.
- (void)enqueueWriteBuffer:(RRCLBuffer *)aBuffer blocking:(cl_bool)blocking offset:(size_t)offset data:(NSData *)data;
- (void)enqueueNDRangeKernel:(RRCLKernel *)aKernel globalWorkSize:(size_t)globalWorkSize;
- (void)enqueueNDRangeKernel:(RRCLKernel *)aKernel globalWorkSize:(size_t)globalWorkSize localWorkSize:(size_t)localWorkSize;

- (void)flush;
- (void)finish;

@end
