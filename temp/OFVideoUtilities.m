//
//  OFVideoUtilities.m
//  ImgProc
//
//  Created by Jamis Johnson on 3/19/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFVideoUtilities.h"
#import <AVFoundation/AVFoundation.h>

@implementation OFVideoUtilities

+ (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

@end