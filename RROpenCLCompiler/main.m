//
//	main.m
//	RROpenCLCompiler
//
//	Created by Kendall Hopkins on 2/18/11.
//	Copyright 2011 SoftwareElves. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "RROpenCL.h"

#include <getopt.h>

int main (int argc, char * argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
	NSString * clFilePath = nil;
	NSString * outFolderPath = nil;
	int c;
	
	while ((c = getopt (argc, argv, "d:o:")) != -1) {
		switch (c) {
			case 'o':
				//output folder
				outFolderPath = [NSString stringWithCString:optarg encoding:NSASCIIStringEncoding];
				break;
			default:
				abort ();
		}
	}
	
	if( optind + 1 < argc ) {
		printf( "To many unmatched args %d\n", argc - optind );
		return 1;
	}
	
	clFilePath = [NSString stringWithCString:argv[optind] encoding:NSASCIIStringEncoding];
	NSCAssert(clFilePath, @"missing cl file path" );
	
	NSArray * devices = [RRCLDevice devicesForPlatform:NULL type:CL_DEVICE_TYPE_ALL];
	NSUInteger device_count = [devices count];
	NSCAssert( device_count > 0, @"must have at least one opencl device" );
	
	RRCLContext * context = [[[RRCLContext alloc] initWithDevices:devices] autorelease];

	NSError * error = nil;
	NSString * program_data = [NSString stringWithContentsOfFile:clFilePath encoding:NSASCIIStringEncoding error:&error];
	RRCLProgram * program = [[[RRCLProgram alloc] initWithSource:program_data inContext:context] autorelease];
	cl_int build_code = [program build];
	if( build_code ) {
		NSLog(@"Fail to build helloworld.cl");
		return 1;
	}

	if( ! [[NSFileManager defaultManager] createDirectoryAtPath:outFolderPath withIntermediateDirectories:YES attributes:nil error:nil] ) {
		NSLog(@"Fail to create directory %@", outFolderPath);		 
	}
		
	NSArray * binarys = [program binarys];
	for( int i = 0; i < device_count; i++ ) {
		NSData * binary = [binarys objectAtIndex:i];
		RRCLDevice * device = [devices objectAtIndex:i];
		NSString * outputBinaryFilePath = [[outFolderPath stringByAppendingPathComponent:[device deviceName]] stringByReplacingOccurrencesOfString:@" " withString:@""];
		BOOL result = [binary writeToFile:outputBinaryFilePath atomically:NO];
		if( ! result ) {
			NSLog(@"Fail to write %@", outputBinaryFilePath );
		}
	}
	
	[pool drain];
	return 0;
}

