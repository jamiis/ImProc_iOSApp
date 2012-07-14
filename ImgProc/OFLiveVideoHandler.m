//
//  OFLiveVideo.m
//  ImgProc
//
//  Created by Jamis Johnson on 3/20/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFLiveVideoHandler.h"
#import "Constants.h"
#import "UIImage-Extensions.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define BYTES_PER_PIXEL 4



@interface OFLiveVideoHandler ()

// Redeclared as readwrite so that we can write to the property and still be atomic with external readers.
@property (readwrite) Float64 videoFrameRate;
@property (readwrite) CMVideoDimensions videoDimensions;
@property (readwrite) CMVideoCodecType videoType;

@property (readwrite, getter=isRecording) BOOL recording;
@property (readwrite, getter=isSessionRunning) BOOL sessionRunning;

@property (readwrite) AVCaptureVideoOrientation videoOrientation;

@end




@implementation OFLiveVideoHandler

@synthesize paused = _paused;

@synthesize delegate;
@synthesize videoFrameRate, videoDimensions, videoType;
@synthesize referenceOrientation;
@synthesize videoOrientation;
@synthesize recording;
@synthesize sessionRunning;

- (id) init
{
    if (self = [super init]) {
        previousSecondTimestamps = [[NSMutableArray alloc] init];
        referenceOrientation = UIDeviceOrientationPortrait;
        
        // The temporary path for the video before saving it to the photo album
        movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"Movie.MOV"]];
        [movieURL retain];
    }
    return self;
}


- (void)dealloc 
{
    [previousSecondTimestamps release];
    [movieURL release];
    
	[super dealloc];
}




#pragma mark - Capture
// Create and configure a capture session and start it running
- (BOOL)setupCaptureSession
{
    _paused = NO;
    
    NSLog(@"setupCaptureSession");
    
	/*
	 * Create capture session
	 */
    captureSession = [[AVCaptureSession alloc] init];
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Configure the session to produce lower resolution video frames
//    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPresetMedium])
//        captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    if ([device supportsAVCaptureSessionPreset:AVCaptureSessionPreset352x288])
        captureSession.sessionPreset = AVCaptureSessionPreset352x288;
    
    /*
	 * Create video connection
	 */
    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];
    if ([captureSession canAddInput:videoIn])
        [captureSession addInput:videoIn];
	[videoIn release];
    
	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
    //TODO: try NOT always discarding late vid frames
	[videoOut setAlwaysDiscardsLateVideoFrames:YES];
	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
	dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
	[videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
	dispatch_release(videoCaptureQueue);
	if ([captureSession canAddOutput:videoOut])
		[captureSession addOutput:videoOut];
	videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
	self.videoOrientation = [videoConnection videoOrientation];
	[videoOut release];
    
	return YES;
    
    
//    
//    // Create a VideoDataOutput and add it to the session
//    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
//    [session addOutput:output];
//    
////    AVCaptureConnection *videoConnection = [
//    
//    // Configure your output.
//    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
//    [output setSampleBufferDelegate:self queue:queue];
//    dispatch_release(queue);
//    
//    // Specify the pixel format
//    output.videoSettings = 
//    [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
//                                forKey:(id)kCVPixelBufferPixelFormatTypeKey];
//    
//    
//    // If you wish to cap the frame rate to a known value, such as 15 fps, set 
//    output.minFrameDuration = CMTimeMake(1, LIVE_VIDEO_FRAMES_PER_SECOND);
//    
//    // Assign session to an ivar.
//    [self setSession:session];
//    [session release];
    
    
    
//    /*
//     Overview: RosyWriter uses separate GCD queues for audio and video capture.  If a single GCD queue
//     is used to deliver both audio and video buffers, and our video processing consistently takes
//     too long, the delivery queue can back up, resulting in audio being dropped.
//     
//     When recording, RosyWriter creates a third GCD queue for calls to AVAssetWriter.  This ensures
//     that AVAssetWriter is not called to start or finish writing from multiple threads simultaneously.
//     
//     RosyWriter uses AVCaptureSession's default preset, AVCaptureSessionPresetHigh.
//	 */
//    
//    /*
//	 * Create capture session
//	 */
//    captureSession = [[AVCaptureSession alloc] init];
//    
//    /*
//	 * Create audio connection
//	 */
//    AVCaptureDeviceInput *audioIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self audioDevice] error:nil];
//    if ([captureSession canAddInput:audioIn])
//        [captureSession addInput:audioIn];
//	[audioIn release];
//	
//	AVCaptureAudioDataOutput *audioOut = [[AVCaptureAudioDataOutput alloc] init];
//	dispatch_queue_t audioCaptureQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
//	[audioOut setSampleBufferDelegate:self queue:audioCaptureQueue];
//	dispatch_release(audioCaptureQueue);
//	if ([captureSession canAddOutput:audioOut])
//		[captureSession addOutput:audioOut];
//	audioConnection = [audioOut connectionWithMediaType:AVMediaTypeAudio];
//	[audioOut release];
//    
//	/*
//	 * Create video connection
//	 */
//    AVCaptureDeviceInput *videoIn = [[AVCaptureDeviceInput alloc] initWithDevice:[self videoDeviceWithPosition:AVCaptureDevicePositionBack] error:nil];
//    if ([captureSession canAddInput:videoIn])
//        [captureSession addInput:videoIn];
//	[videoIn release];
//    
//	AVCaptureVideoDataOutput *videoOut = [[AVCaptureVideoDataOutput alloc] init];
//	/*
//     RosyWriter prefers to discard late video frames early in the capture pipeline, since its
//     processing can take longer than real-time on some platforms (such as iPhone 3GS).
//     Clients whose image processing is faster than real-time should consider setting AVCaptureVideoDataOutput's
//     alwaysDiscardsLateVideoFrames property to NO. 
//	 */
//	[videoOut setAlwaysDiscardsLateVideoFrames:YES];
//	[videoOut setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
//	dispatch_queue_t videoCaptureQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
//	[videoOut setSampleBufferDelegate:self queue:videoCaptureQueue];
//	dispatch_release(videoCaptureQueue);
//	if ([captureSession canAddOutput:videoOut])
//		[captureSession addOutput:videoOut];
//	videoConnection = [videoOut connectionWithMediaType:AVMediaTypeVideo];
//	self.videoOrientation = [videoConnection videoOrientation];
//	[videoOut release];
//    
//	return YES;
}


- (void) setupAndStartCaptureSession
{
	// Create a shallow queue for buffers going to the display for preview.
//	OSStatus err = CMBufferQueueCreate(kCFAllocatorDefault, 1, CMBufferQueueGetCallbacksForUnsortedSampleBuffers(), &previewBufferQueue);
//	if (err)
//		[self showError:[NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil]];
	
	// Create serial queue for movie writing
	movieWritingQueue = dispatch_queue_create("Movie Writing Queue", DISPATCH_QUEUE_SERIAL);
	
    if ( !captureSession )
		[self setupCaptureSession];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(captureSessionStoppedRunningNotification:) name:AVCaptureSessionDidStopRunningNotification object:captureSession];
	
//	if ( !captureSession.isRunning ) {
//		[captureSession startRunning];
//        sessionRunning = YES;
//    }
}


- (void) pauseCaptureSession
{
    NSLog(@"pauseCaptureSession");
	if ( captureSession.isRunning ) {
		[captureSession stopRunning];
        sessionRunning = NO;
    }
}

- (void) resumeCaptureSession
{
    NSLog(@"resumeCaptureSession");
	if ( !captureSession.isRunning ) {
		[captureSession startRunning];
        sessionRunning = YES;
    }
}

- (void)captureSessionStoppedRunningNotification:(NSNotification *)notification
{
    NSLog(@"captureSessionStoppedRunningNotification");
	dispatch_async(movieWritingQueue, ^{
		if ( [self isRecording] ) {
			[self stopRecording];
		}
	});
}


- (void) stopAndTearDownCaptureSession
{
    NSLog(@"stopAndTearDownCaptureSession");
    [captureSession stopRunning];
    sessionRunning = NO;
	if (captureSession)
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureSessionDidStopRunningNotification object:captureSession];
	[captureSession release];
	captureSession = nil;
	if (previewBufferQueue) {
		CFRelease(previewBufferQueue);
		previewBufferQueue = NULL;	
	}
	if (movieWritingQueue) {
		dispatch_release(movieWritingQueue);
		movieWritingQueue = NULL;
	}
}


// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
       fromConnection:(AVCaptureConnection *)connection
{
//    NSLog(@"captureOutput delegate: start");
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
	if ( connection == videoConnection ) {
		
		// Get framerate
		CMTime timestamp = CMSampleBufferGetPresentationTimeStamp( sampleBuffer );
		[self calculateFramerateAtTimestamp:timestamp];
        
		// Get frame dimensions (for onscreen display)
		if (self.videoDimensions.width == 0 && self.videoDimensions.height == 0)
			self.videoDimensions = CMVideoFormatDescriptionGetDimensions( formatDescription );
		
		// Get buffer type
		if ( self.videoType == 0 )
			self.videoType = CMFormatDescriptionGetMediaSubType( formatDescription );
        
        // processCMSampleBufferRef to change pixels
        // turn that into a UIImage?
        

        
        
		CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [delegate processPixelBuffer:pixelBuffer];
        
        
        
        /*
         *  Display preview
         */
        // TODO: IF NO ALGORITHM IS RUNNING, DON'T PROCESS IMAGE?
        // TODO: RETAIN IMAGE?
        // Create a UIImage from the sample buffer data
        UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate setNewFilteredImage:image];
        });
        
        
//		CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
		//TODO: PROCESS IMAGE HERE!
        // Synchronously process the pixel buffer to de-green it.
//		[self processPixelBuffer:pixelBuffer];
        
		//TODO: PREVIEW IMAGE VIA UIIMAGE
		// Enqueue it for preview.  This is a shallow queue, so if image processing is taking too long,
		// we'll drop this frame for preview (this keeps preview latency low).
//		OSStatus err = CMBufferQueueEnqueue(previewBufferQueue, sampleBuffer);
//		if ( !err ) {        
//			dispatch_async(dispatch_get_main_queue(), ^{
//				CMSampleBufferRef sbuf = (CMSampleBufferRef)CMBufferQueueDequeueAndRetain(previewBufferQueue);
//				if (sbuf) {
//					CVImageBufferRef pixBuf = CMSampleBufferGetImageBuffer(sbuf);
//					[self.delegate pixelBufferReadyForDisplay:pixBuf];
//					CFRelease(sbuf);
//				}
//			});
//		}
	}
    
	CFRetain(sampleBuffer);
	CFRetain(formatDescription);
	dispatch_async(movieWritingQueue, ^{
        
		if ( assetWriter ) {
            
            NSLog(@"captureOutput delegate: assetWriter");
            
			BOOL wasReadyToRecord = readyToRecordVideo;
			
			if (connection == videoConnection) {
				
				// Initialize the video input if this is not done yet
				if (!readyToRecordVideo) {
                    NSLog(@"captureOutput delegate: init video input");
					readyToRecordVideo = [self setupAssetWriterVideoInput:formatDescription];
                }
				
				// Write video data to file
				if (readyToRecordVideo) {
//                    NSLog(@"captureOutput delegate: write video data");
					[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeVideo];
                }
			}
//			else if (connection == audioConnection) {
//				
//				// Initialize the audio input if this is not done yet
//				if (!readyToRecordAudio)
//					readyToRecordAudio = [self setupAssetWriterAudioInput:formatDescription];
//				
//				// Write audio data to file
//				if (readyToRecordAudio && readyToRecordVideo)
//					[self writeSampleBuffer:sampleBuffer ofType:AVMediaTypeAudio];
//			}
			
			BOOL isReadyToRecord = readyToRecordVideo;
			if ( !wasReadyToRecord && isReadyToRecord ) {
                NSLog(@"captureOutput delegate: !wasReadyToRecord && isReadyToRecord");
				recordingWillBeStarted = NO;
				self.recording = YES;
				[self.delegate recordingDidStart];
			}
		}
		CFRelease(sampleBuffer);
		CFRelease(formatDescription);
	});
    
    
//    
//    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
//    
////    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
////    NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
////    UIImage *image = [[UIImage alloc] initWithData:imgData];
//    
//    // Create a UIImage from the sample buffer data
//    UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
//    
//    //NSLog(@"capture size w: %3.2f, h: %3.2f", image.size.width, image.size.height);
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[self delegate] setNewFilteredImage:image];
//    });
}


- (AVCaptureDevice *)videoDeviceWithPosition:(AVCaptureDevicePosition)position 
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
        if ([device position] == position)
            return device;
    
    return nil;
}




#pragma mark - Recording From Image Array
//- (void)recordMovieFromImageArray:(NSMutableArray*)array toPath:(NSString*)path size:(CGSize)size duration:(int)duration;
//{
//    NSError *error = nil; 
//    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:path]  
//                                                           fileType:AVFileTypeMPEG4  
//                                                              error:&error]; 
//    NSParameterAssert(videoWriter); 
//    
//    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys: 
//                                   AVVideoCodecH264, AVVideoCodecKey, 
//                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey, 
//                                   [NSNumber numberWithInt:size.height], AVVideoHeightKey, 
//                                   nil]; 
//    AVAssetWriterInput* writerInput = [[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo 
//                                                                          outputSettings:videoSettings] retain]; 
//    
//    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput 
//                                                                                                                     sourcePixelBufferAttributes:nil]; 
//    NSParameterAssert(writerInput); 
//    NSParameterAssert([videoWriter canAddInput:writerInput]); 
//    [videoWriter addInput:writerInput]; 
//    
//    
//    // start a session: 
//    [videoWriter startWriting]; 
//    [videoWriter startSessionAtSourceTime:kCMTimeZero]; 
//    
//    CVPixelBufferRef buffer = NULL; 
//    buffer = [self pixelBufferFromCGImage:[[[array objectAtIndex:0] imageRotatedByDegrees:-90.0] CGImage] size:size]; 
//    CVPixelBufferPoolCreatePixelBuffer (NULL, adaptor.pixelBufferPool, &buffer); 
//    
//    //[adaptor appendPixelBuffer:buffer withPresentationTime:kCMTimeZero]; 
//    
//    int i = 0;
//    while (TRUE) 
//    {
//		if(writerInput.readyForMoreMediaData)
//        {
//			CMTime frameTime = CMTimeMake(1, 10);
//			CMTime lastTime=CMTimeMake(i, 10);
//			CMTime presentTime=CMTimeAdd(lastTime, frameTime);
//			
//			if (i >= [array count]) {
//				buffer = NULL;
//			} 
//			else {
//                UIImage *image = [array objectAtIndex:i];
//                //                UIImage *image = [[array objectAtIndex:i] imageRotatedByDegrees:-90.0];
//				buffer = [self pixelBufferFromCGImage:image.CGImage size:size];
//			}          
//			
//			
//			if (buffer) {
//				// append buffer
//				[adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
//				i++;
//			} 
//			else {
//				
//				//Finish the session:
//				[writerInput markAsFinished];
//				[videoWriter finishWriting];                
//				
//				CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
//				
//				
//				[videoWriter release];
//				[writerInput release];
//				NSLog (@"Recording is done");
//				break;
//			}
//		}
//    }
//}


- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)imageSize
{
    NSLog(@"pixelBufferFromCGImage");
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, imageSize.width,
                                          imageSize.height, kCVPixelFormatType_32ARGB, (CFDictionaryRef) options, 
                                          &pxbuffer);
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, imageSize.width,
                                                 imageSize.height, 8, 4*imageSize.width, rgbColorSpace, 
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    //    CGContextConcatCTM(context, frameTransform);
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), 
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}




#pragma mark - Processing
// Create a UIImage from sample buffer data
- (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer 
{
    //NSLog(@"imageFromSampleBuffer");
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, 
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
//    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [[[UIImage alloc] initWithCGImage:quartzImage scale:1.0 orientation:videoOrientation] autorelease];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}


//- (void)processPixelBuffer: (CVImageBufferRef)pixelBuffer 
//{
//	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
//	
//	int bufferWidth = CVPixelBufferGetWidth(pixelBuffer);
//	int bufferHeight = CVPixelBufferGetHeight(pixelBuffer);
//	unsigned char *pixel = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
//    
//	for( int row = 0; row < bufferHeight; row++ ) {		
//		for( int column = 0; column < bufferWidth; column++ ) {
//			pixel[1] = 0; // De-green (second pixel in BGRA is green)
//			pixel += BYTES_PER_PIXEL;
//		}
//	}
//	
//	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
//}




#pragma mark Recording
- (void)saveMovieToCameraRoll
{
    NSLog(@"saveMovieToCameraRoll");
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
	[library writeVideoAtPathToSavedPhotosAlbum:movieURL
								completionBlock:^(NSURL *assetURL, NSError *error) {
									if (error)
										[self showError:error];
									else
										[self removeFile:movieURL];
									
									dispatch_async(movieWritingQueue, ^{
										recordingWillBeStopped = NO;
										self.recording = NO;
										
										[self.delegate recordingDidStop];
									});
								}];
	[library release];
}


- (void) writeSampleBuffer:(CMSampleBufferRef)sampleBuffer ofType:(NSString *)mediaType
{
    NSLog(@"writeSampleBuffer");
	if ( assetWriter.status == AVAssetWriterStatusUnknown ) {
		
        if ([assetWriter startWriting]) {			
			[assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
		}
		else {
			[self showError:[assetWriter error]];
		}
	}
	
	if ( assetWriter.status == AVAssetWriterStatusWriting ) {
		
		if (mediaType == AVMediaTypeVideo) {
			if (assetWriterVideoIn.readyForMoreMediaData) {
				if (![assetWriterVideoIn appendSampleBuffer:sampleBuffer]) {
					[self showError:[assetWriter error]];
				}
			}
		}
		else if (mediaType == AVMediaTypeAudio) {
			if (assetWriterAudioIn.readyForMoreMediaData) {
				if (![assetWriterAudioIn appendSampleBuffer:sampleBuffer]) {
					[self showError:[assetWriter error]];
				}
			}
		}
	}
}


//- (BOOL) setupAssetWriterAudioInput:(CMFormatDescriptionRef)currentFormatDescription
//{
//	const AudioStreamBasicDescription *currentASBD = CMAudioFormatDescriptionGetStreamBasicDescription(currentFormatDescription);
//    
//	size_t aclSize = 0;
//	const AudioChannelLayout *currentChannelLayout = CMAudioFormatDescriptionGetChannelLayout(currentFormatDescription, &aclSize);
//	NSData *currentChannelLayoutData = nil;
//	
//	// AVChannelLayoutKey must be specified, but if we don't know any better give an empty data and let AVAssetWriter decide.
//	if ( currentChannelLayout && aclSize > 0 )
//		currentChannelLayoutData = [NSData dataWithBytes:currentChannelLayout length:aclSize];
//	else
//		currentChannelLayoutData = [NSData data];
//	
//	NSDictionary *audioCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//											  [NSNumber numberWithInteger:kAudioFormatMPEG4AAC], AVFormatIDKey,
//											  [NSNumber numberWithFloat:currentASBD->mSampleRate], AVSampleRateKey,
//											  [NSNumber numberWithInt:64000], AVEncoderBitRatePerChannelKey,
//											  [NSNumber numberWithInteger:currentASBD->mChannelsPerFrame], AVNumberOfChannelsKey,
//											  currentChannelLayoutData, AVChannelLayoutKey,
//											  nil];
//	if ([assetWriter canApplyOutputSettings:audioCompressionSettings forMediaType:AVMediaTypeAudio]) {
//		assetWriterAudioIn = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioCompressionSettings];
//		assetWriterAudioIn.expectsMediaDataInRealTime = YES;
//		if ([assetWriter canAddInput:assetWriterAudioIn])
//			[assetWriter addInput:assetWriterAudioIn];
//		else {
//			NSLog(@"Couldn't add asset writer audio input.");
//            return NO;
//		}
//	}
//	else {
//		NSLog(@"Couldn't apply audio output settings.");
//        return NO;
//	}
//    
//    return YES;
//}

- (BOOL) setupAssetWriterVideoInput:(CMFormatDescriptionRef)currentFormatDescription 
{
    NSLog(@"setupAssetWriterVideoInput");
	float bitsPerPixel;
	CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(currentFormatDescription);
	int numPixels = dimensions.width * dimensions.height;
	int bitsPerSecond;
	
	// Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
	if ( numPixels < (640 * 480) )
		bitsPerPixel = 4.05; // This bitrate matches the quality produced by AVCaptureSessionPresetMedium or Low.
	else
		bitsPerPixel = 11.4; // This bitrate matches the quality produced by AVCaptureSessionPresetHigh.
	
	bitsPerSecond = numPixels * bitsPerPixel;
	
	NSDictionary *videoCompressionSettings = [NSDictionary dictionaryWithObjectsAndKeys:
											  AVVideoCodecH264, AVVideoCodecKey,
											  [NSNumber numberWithInteger:dimensions.width], AVVideoWidthKey,
											  [NSNumber numberWithInteger:dimensions.height], AVVideoHeightKey,
											  [NSDictionary dictionaryWithObjectsAndKeys:
											   [NSNumber numberWithInteger:bitsPerSecond], AVVideoAverageBitRateKey,
											   [NSNumber numberWithInteger:30], AVVideoMaxKeyFrameIntervalKey,
											   nil], AVVideoCompressionPropertiesKey,
											  nil];
	if ([assetWriter canApplyOutputSettings:videoCompressionSettings forMediaType:AVMediaTypeVideo]) {
		assetWriterVideoIn = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoCompressionSettings];
		assetWriterVideoIn.expectsMediaDataInRealTime = YES;
		assetWriterVideoIn.transform = [self transformFromCurrentVideoOrientationToOrientation:self.referenceOrientation];
		if ([assetWriter canAddInput:assetWriterVideoIn])
			[assetWriter addInput:assetWriterVideoIn];
		else {
			NSLog(@"Couldn't add asset writer video input.");
            return NO;
		}
	}
	else {
		NSLog(@"Couldn't apply video output settings.");
        return NO;
	}
    
    return YES;
}


- (void) startRecording
{
    NSLog(@"startRecording");
	dispatch_async(movieWritingQueue, ^{
        
		if ( recordingWillBeStarted || self.recording )
			return;
        
		recordingWillBeStarted = YES;
        
		// recordingDidStart is called from captureOutput:didOutputSampleBuffer:fromConnection: once the asset writer is setup
		[self.delegate recordingWillStart];
        
		// Remove the file if one with the same name already exists
		[self removeFile:movieURL];
        
		// Create an asset writer
		NSError *error;
		assetWriter = [[AVAssetWriter alloc] initWithURL:movieURL fileType:(NSString *)kUTTypeQuickTimeMovie error:&error];
		if (error)
			[self showError:error];
	});	
}


- (void) stopRecording
{
    NSLog(@"stopRecording");
	dispatch_async(movieWritingQueue, ^{
		
		if ( recordingWillBeStopped || (self.recording == NO) )
			return;
		
		recordingWillBeStopped = YES;
		
		// recordingDidStop is called from saveMovieToCameraRoll
		[self.delegate recordingWillStop];
        
		if ([assetWriter finishWriting]) {
			[assetWriterAudioIn release];
			[assetWriterVideoIn release];
			[assetWriter release];
			assetWriter = nil;
			
			readyToRecordVideo = NO;
//			readyToRecordAudio = NO;
			
			[self saveMovieToCameraRoll];
		}
		else {
			[self showError:[assetWriter error]];
		}
	});
}




#pragma mark Error Handling
- (void)showError:(NSError *)error
{
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription]
                                                            message:[error localizedFailureReason]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
    });
}




#pragma mark Utilities
- (void) calculateFramerateAtTimestamp:(CMTime) timestamp
{
	[previousSecondTimestamps addObject:[NSValue valueWithCMTime:timestamp]];
    
	CMTime oneSecond = CMTimeMake( 1, 1 );
	CMTime oneSecondAgo = CMTimeSubtract( timestamp, oneSecond );
    
	while( CMTIME_COMPARE_INLINE( [[previousSecondTimestamps objectAtIndex:0] CMTimeValue], <, oneSecondAgo ) )
		[previousSecondTimestamps removeObjectAtIndex:0];
    
	Float64 newRate = (Float64) [previousSecondTimestamps count];
	self.videoFrameRate = (self.videoFrameRate + newRate) / 2;
}


- (void)removeFile:(NSURL *)fileURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [fileURL path];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
		if (!success)
			[self showError:error];
    }
}


- (CGFloat)angleOffsetFromPortraitOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGFloat angle = 0.0;
	
	switch (orientation) {
		case AVCaptureVideoOrientationPortrait:
			angle = 0.0;
			break;
		case AVCaptureVideoOrientationPortraitUpsideDown:
			angle = M_PI;
			break;
		case AVCaptureVideoOrientationLandscapeRight:
			angle = -M_PI_2;
			break;
		case AVCaptureVideoOrientationLandscapeLeft:
			angle = M_PI_2;
			break;
		default:
			break;
	}
    
	return angle;
}


- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation
{
	CGAffineTransform transform = CGAffineTransformIdentity;
    
	// Calculate offsets from an arbitrary reference orientation (portrait)
	CGFloat orientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:orientation];
	CGFloat videoOrientationAngleOffset = [self angleOffsetFromPortraitOrientationToOrientation:self.videoOrientation];
	
	// Find the difference in angle between the passed in orientation and the current video orientation
	CGFloat angleOffset = orientationAngleOffset - videoOrientationAngleOffset;
	transform = CGAffineTransformMakeRotation(angleOffset);
	
	return transform;
}

@end
