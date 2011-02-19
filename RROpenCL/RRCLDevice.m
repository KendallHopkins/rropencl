// RROpenCL RRCLDevice.m
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

#import "RRCLDevice.h"
#import "RRCLException.h"

@interface RRCLDevice ()

- (id)initWithDeviceID:(cl_device_id)aDeviceID;

@end

@implementation RRCLDevice

+ (RRCLDevice *)defaultDevice
{
	static RRCLDevice * defaultDevice = nil;
	if( ! defaultDevice ) {
		NSArray * deviceArray = [self devicesForPlatform:NULL type:CL_DEVICE_TYPE_DEFAULT];
		defaultDevice = [deviceArray objectAtIndex:0];
	}
	return defaultDevice;
}

+ (NSArray *)devicesForPlatform:(cl_platform_id)platformID type:(cl_device_type)deviceType
{
	cl_uint count;
	cl_int errorCode;
	errorCode = clGetDeviceIDs(platformID, deviceType, 0, NULL, &count);
	
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
	
	cl_device_id ids[count];
	errorCode = clGetDeviceIDs(platformID, deviceType, count, ids, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
	
	RRCLDevice * devices[count];
	for (cl_uint index = 0; index < count; index++) {
		devices[index] = [[RRCLDevice alloc] initWithDeviceID:ids[index]];
	}
	NSArray * answer = [NSArray arrayWithObjects:devices count:count];
	for (cl_uint index = 0; index < count; index++) {
		[devices[index] release];
	}
	return answer;
}

- (id)initWithDeviceID:(cl_device_id)aDeviceID
{
	self = [super init];
	if (self) {
		clDeviceId = aDeviceID;
	}
	return self;
}

- (cl_device_id)clDeviceId
{
	return clDeviceId;
}

- (NSString *)stringForDeviceInfo:(cl_device_info)deviceInfo
{
	size_t size;
	cl_int errorCode;
	errorCode = clGetDeviceInfo(clDeviceId, deviceInfo, 0, NULL, &size);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];

	char info[size];
	errorCode = clGetDeviceInfo(clDeviceId, deviceInfo, size, info, NULL);
	if (CL_SUCCESS != errorCode)
		[RRCLException raiseWithErrorCode:errorCode];
	
	return [NSString stringWithCString:info encoding:NSASCIIStringEncoding];
}
- (NSString *)deviceName
{
	return [self stringForDeviceInfo:CL_DEVICE_NAME];
}
- (NSString *)deviceVendor
{
	return [self stringForDeviceInfo:CL_DEVICE_VENDOR];
}
- (NSString *)driverVersion
{
	return [self stringForDeviceInfo:CL_DRIVER_VERSION];
}
- (NSString *)deviceProfile
{
	return [self stringForDeviceInfo:CL_DEVICE_PROFILE];
}
- (NSString *)deviceVersion
{
	return [self stringForDeviceInfo:CL_DEVICE_VERSION];
}
- (NSString *)deviceExtensions
{
	return [self stringForDeviceInfo:CL_DEVICE_EXTENSIONS];
}
- (NSString *)description
{
	return [NSString stringWithFormat:@"OpenCL device name=%@ vendor=%@", [self deviceName], [self deviceVendor]];
}

@end
