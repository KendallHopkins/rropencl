// RROpenCL RRCLContext.m
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

#import "RRCLContext.h"
#import "RRCLDevice.h"
#import "RRCLCommandQueue.h"
#import "RRCLProgram.h"
#import "RRCLBuffer.h"

void RRCLContextNotify(const char *errinfo, const void *private_info, size_t cb, void *user_data);

@implementation RRCLContext

- (id)initWithDevices:(NSArray *)devices
{
	self = [super init];
	if (self)
	{
		NSUInteger count = [devices count];
		cl_device_id ids[count];
		for (NSUInteger index = 0; index < count; index++) {
			ids[index] = [[devices objectAtIndex:index] clDeviceId];
		}
		cl_int errcode;
		clContext = clCreateContext(NULL, (cl_uint)count, ids, RRCLContextNotify, self, &errcode);
		if (CL_SUCCESS != errcode) {
			[self release];
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	clReleaseContext(clContext);
	[super dealloc];
}
- (void)finalize
{
	clReleaseContext(clContext);
	[super finalize];
}

- (RRCLCommandQueue *)commandQueueForDevice:(RRCLDevice *)aDevice
{
	return [[[RRCLCommandQueue alloc] initWithContext:self device:aDevice] autorelease];
}

- (RRCLBuffer *)readWriteBufferWithSize:(size_t)size
{
	return [[[RRCLBuffer alloc] initReadWriteWithContext:self size:size] autorelease];
}
- (RRCLBuffer *)writeOnlyBufferWithSize:(size_t)size
{
	return [[[RRCLBuffer alloc] initWriteOnlyWithContext:self size:size] autorelease];
}
- (RRCLBuffer *)readOnlyBufferWithSize:(size_t)size
{
	return [[[RRCLBuffer alloc] initReadOnlyWithContext:self size:size] autorelease];
}

- (cl_context)clContext
{
	return clContext;
}

- (void)notifyWithErrorInfo:(NSString *)errInfo data:(NSData *)data
{
	NSLog(@"%@ %@ %@", self, errInfo, data);
}

@end

void RRCLContextNotify(const char *errinfo, const void *private_info, size_t cb, void *user_data)
{
	[(RRCLContext *)user_data notifyWithErrorInfo:[NSString stringWithCString:errinfo encoding:NSASCIIStringEncoding] data:[NSData dataWithBytes:private_info length:cb]];
}
