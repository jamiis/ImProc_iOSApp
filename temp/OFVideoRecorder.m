//
//  OFVideoRecorder.m
//  ImgProc
//
//  Created by Jamis Johnson on 3/19/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFVideoRecorder.h"
#import "OFVideoUtilities.h"
#import <AVFoundation/AVFoundation.h>

@interface OFVideoRecorder (FileOutputDelegate) <AVCaptureFileOutputRecordingDelegate>
@end

@implementation OFVideoRecorder

@synthesize session;
@synthesize movieFileOutput;
@synthesize outputFileURL;
@synthesize delegate;

- (id) initWithSession:(AVCaptureSession *)aSession outputFileURL:(NSURL *)anOutputFileURL
{
    self = [super init];
    if (self != nil) {
        AVCaptureMovieFileOutput *aMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([aSession canAddOutput:aMovieFileOutput])
            [aSession addOutput:aMovieFileOutput];
        [self setMovieFileOutput:aMovieFileOutput];
        [aMovieFileOutput release];
		
		[self setSession:aSession];
		[self setOutputFileURL:anOutputFileURL];
    }
    
	return self;
}

- (void) dealloc
{
    [[self session] removeOutput:[self movieFileOutput]];
	[session release];
	[outputFileURL release];
	[movieFileOutput release];
    [super dealloc];
}

-(BOOL)recordsVideo
{
	AVCaptureConnection *videoConnection = [OFVideoUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self movieFileOutput] connections]];
	return [videoConnection isActive];
}

-(BOOL)recordsAudio
{
	AVCaptureConnection *audioConnection = [OFVideoUtilities connectionWithMediaType:AVMediaTypeAudio fromConnections:[[self movieFileOutput] connections]];
	return [audioConnection isActive];
}

-(BOOL)isRecording
{
    return [[self movieFileOutput] isRecording];
}

-(void)startRecordingWithOrientation:(AVCaptureVideoOrientation)videoOrientation;
{
    AVCaptureConnection *videoConnection = [OFVideoUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self movieFileOutput] connections]];
    if ([videoConnection isVideoOrientationSupported])
        [videoConnection setVideoOrientation:videoOrientation];
    
    [[self movieFileOutput] startRecordingToOutputFileURL:[self outputFileURL] recordingDelegate:self];
}

-(void)stopRecording
{
    [[self movieFileOutput] stopRecording];
}

@end

@implementation OFVideoRecorder (FileOutputDelegate)

- (void)             captureOutput:(AVCaptureFileOutput *)captureOutput
didStartRecordingToOutputFileAtURL:(NSURL *)fileURL
                   fromConnections:(NSArray *)connections
{
    if ([[self delegate] respondsToSelector:@selector(recorderRecordingDidBegin:)]) {
        [[self delegate] recorderRecordingDidBegin:self];
    }
}

- (void)              captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)anOutputFileURL
                    fromConnections:(NSArray *)connections
                              error:(NSError *)error
{
    if ([[self delegate] respondsToSelector:@selector(recorder:recordingDidFinishToOutputFileURL:error:)]) {
        [[self delegate] recorder:self recordingDidFinishToOutputFileURL:anOutputFileURL error:error];
    }
}

@end
