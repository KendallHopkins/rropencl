// RROpenCL RRCLProgram.m
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

#import "RRCLProgram.h"
#import "RRCLKernel.h"
#import "RRCLContext.h"
#import "RRCLDevice.h"

@implementation RRCLProgram

- (id)initWithProgram:(cl_program)otherProgram
{
	self = [super init];
	if (self)
	{
		clRetainProgram(program = otherProgram);
	}
	return self;
}

- (id)initWithSource:(NSString *)source inContext:(RRCLContext *)aContext
{
	self = [super init];
	if (self)
	{
		cl_int errcode;
		const char *string = [source cStringUsingEncoding:NSASCIIStringEncoding];
		program = clCreateProgramWithSource([aContext context], 1, &string, NULL, &errcode);
		if (CL_SUCCESS != errcode)
		{
			[self release];
			self = nil;
		}
	}
	return self;
}

- (id)initWithBinarys:(NSArray *)binarys forDevices:(NSArray *)devices inContext:(RRCLContext *)aContext
{
	if( [binarys count] != [devices count] ) {
		[self release];
		self = nil;
	}
	
	self = [super init];
	if (self)
	{
		cl_int errcode;
		cl_uint binary_count = (cl_uint)[binarys count];
		cl_device_id device_array[binary_count];
		size_t binary_size_array[binary_count];
		cl_int binary_status_array[binary_count];
		const unsigned char * binary_array[binary_count];
		for( int i = 0; i < binary_count; i++ ) {
			RRCLDevice * device = [devices objectAtIndex:i];
			device_array[i] = [device deviceID];
			NSData * binary = [binarys objectAtIndex:i];
			binary_size_array[i] = [binary length];
			binary_array[i] = [binary bytes];
		}
		
		program = clCreateProgramWithBinary([aContext context], binary_count, device_array, binary_size_array, binary_array, binary_status_array, &errcode);
		if (CL_SUCCESS != errcode)
		{
			[self release];
			self = nil;
		}
	}
	return self;
}

- (void)dealloc
{
	clReleaseProgram(program);
	[super dealloc];
}
- (void)finalize
{
	clReleaseProgram(program);
	[super finalize];
}

- (cl_int)build
{
	return clBuildProgram(program, 0, NULL, "", NULL, NULL);
}

//------------------------------------------------------------------------------
#pragma mark																Info
//------------------------------------------------------------------------------

- (cl_uint)numberOfDevices
{
	cl_uint numberOfDevices;
	if (CL_SUCCESS != clGetProgramInfo(program, CL_PROGRAM_NUM_DEVICES, sizeof(numberOfDevices), &numberOfDevices, NULL))
	{
		return 0;
	}
	return numberOfDevices;
}

- (NSArray *)binarys
{
	cl_uint numberOfDevices = [self numberOfDevices];
	size_t binarySizes[numberOfDevices];
	if (CL_SUCCESS != clGetProgramInfo(program, CL_PROGRAM_BINARY_SIZES, sizeof(size_t)*numberOfDevices, binarySizes, NULL))
	{
		return nil;
	}
	
	NSMutableArray * binarys_array = [NSMutableArray arrayWithCapacity:numberOfDevices];
	unsigned char * binarys[numberOfDevices];
	for( int i = 0; i < numberOfDevices; i++ ) {
		size_t binarySize = binarySizes[i];
		binarys[i] = (unsigned char *)malloc(binarySize);
	}
	
	if (CL_SUCCESS != clGetProgramInfo(program, CL_PROGRAM_BINARIES, sizeof(unsigned char *)*numberOfDevices, binarys, NULL))
	{
		return nil;
	}
	for( int i = 0; i < numberOfDevices; i++ ) {
		size_t binarySize = binarySizes[i];
		unsigned char * binary = binarys[i];
		[binarys_array addObject:[NSData dataWithBytes:binary length:binarySize]];
	}
	return binarys_array;
}

//------------------------------------------------------------------------------
#pragma mark														  Build Info
//------------------------------------------------------------------------------

- (cl_build_status)statusForDeviceID:(cl_device_id)deviceID
{
	// Returns the error code if not successful, e.g. returns CL_INVALID_DEVICE
	// if deviceID is not in the list of devices associated with the program.
	// Doing this makes an important assumption about build status codes and
	// error codes. It assumes the two domains do not overlap for the building
	// information context. This turns out to be true for OpenCL version 1.0 but
	// may not always remain true.
	cl_build_status status;
	cl_int errcode;
	if (CL_SUCCESS != (errcode = clGetProgramBuildInfo(program, deviceID, CL_PROGRAM_BUILD_STATUS, sizeof(status), &status, NULL)))
	{
		return errcode;
	}
	return status;
}

- (NSString *)stringForBuildInfo:(cl_program_build_info)buildInfo deviceID:(cl_device_id)deviceID
{
	size_t size;
	if (CL_SUCCESS != clGetProgramBuildInfo(program, deviceID, buildInfo, 0, NULL, &size))
	{
		return nil;
	}
	char info[size];
	if (CL_SUCCESS != clGetProgramBuildInfo(program, deviceID, buildInfo, size, info, NULL))
	{
		return nil;
	}
	return [NSString stringWithCString:info encoding:NSASCIIStringEncoding];
}

- (NSString *)optionsForDeviceID:(cl_device_id)deviceID
{
	return [self stringForBuildInfo:CL_PROGRAM_BUILD_OPTIONS deviceID:deviceID];
}

- (NSString *)logForDeviceID:(cl_device_id)deviceID
{
	return [self stringForBuildInfo:CL_PROGRAM_BUILD_LOG deviceID:deviceID];
}

- (RRCLKernel *)kernelWithName:(NSString *)kernelName
{
	return [[[RRCLKernel alloc] initWithKernelName:kernelName inProgram:program] autorelease];
}

@end
