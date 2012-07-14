//
//  OFLiveVideo.h
//  ImgProc
//
//  Created by Jamis Johnson on 3/20/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CMBufferQueue.h>

@class OFLiveVideoHandler;
@protocol OFLiveVideoDelegate;

@interface OFLiveVideoHandler : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> 
{
    id <OFLiveVideoDelegate> delegate;
    
    NSMutableArray *previousSecondTimestamps;
	Float64 videoFrameRate;
	CMVideoDimensions videoDimensions;
	CMVideoCodecType videoType;
    
    AVCaptureSession *captureSession;
    AVCaptureConnection *videoConnection;
	CMBufferQueueRef previewBufferQueue;
    
	NSURL *movieURL;
	AVAssetWriter *assetWriter;
	AVAssetWriterInput *assetWriterAudioIn;
	AVAssetWriterInput *assetWriterVideoIn;
	dispatch_queue_t movieWritingQueue;
    
	AVCaptureVideoOrientation referenceOrientation;
	AVCaptureVideoOrientation videoOrientation;
    
    // Only accessed on movie writing queue
    BOOL readyToRecordAudio; 
    BOOL readyToRecordVideo;
    BOOL recordingWillBeStarted;
    BOOL recordingWillBeStopped;
    
    BOOL recording;
    BOOL sessionRunning;
    
    BOOL _paused;
}

@property (nonatomic, retain) id <OFLiveVideoDelegate> delegate;

@property (readonly) Float64 videoFrameRate;
@property (readonly) CMVideoDimensions videoDimensions;
@property (readonly) CMVideoCodecType videoType;

@property (readwrite) AVCaptureVideoOrientation referenceOrientation;

@property(readonly, getter=isRecording) BOOL recording;
@property(readonly, getter=isSessionRunning) BOOL sessionRunning;

//@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, getter=isPaused) BOOL paused;


- (BOOL)setupCaptureSession;
//- (void)recordMovieFromImageArray:(NSArray*)array 
//                           toPath:(NSString*)path 
//                             size:(CGSize)size 
//                         duration:(int)duration;


- (CGAffineTransform)transformFromCurrentVideoOrientationToOrientation:(AVCaptureVideoOrientation)orientation;

- (void) showError:(NSError*)error;

- (void) setupAndStartCaptureSession;
- (void) stopAndTearDownCaptureSession;

- (void) startRecording;
- (void) stopRecording;

- (void) pauseCaptureSession; // Pausing while a recording is in progress will cause the recording to be stopped and saved.
- (void) resumeCaptureSession;

@end

@protocol OFLiveVideoDelegate <NSObject>
@required
- (void)setNewFilteredImage:(UIImage *)image;
//- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;	// This method is always called on the main thread.
- (void)recordingWillStart;
- (void)recordingDidStart;
- (void)recordingWillStop;
- (void)recordingDidStop;
@optional
- (void)processPixelBuffer:(CVImageBufferRef)pixelBuffer;
@end
