//
//  OFVideoCaptureManager.h
//  ImgProc
//
//  Created by Jamis Johnson on 3/19/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class OFVideoRecorder;
@protocol OFVideoCaptureManagerDelegate;

@interface OFVideoCaptureManager : NSObject {
    
}

@property (nonatomic,retain) AVCaptureSession *session;
@property (nonatomic,assign) AVCaptureVideoOrientation orientation;
@property (nonatomic,retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic,retain) AVCaptureDeviceInput *audioInput;
@property (nonatomic,retain) AVCaptureStillImageOutput *stillImageOutput;
@property (nonatomic,retain) OFVideoRecorder *recorder;
@property (nonatomic,assign) id deviceConnectedObserver;
@property (nonatomic,assign) id deviceDisconnectedObserver;
@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic,assign) id <OFVideoCaptureManagerDelegate> delegate;

- (BOOL) setupSession;
- (void) startRecording;
- (void) stopRecording;
- (void) captureStillImage;
- (BOOL) toggleCamera;
- (NSUInteger) cameraCount;
- (NSUInteger) micCount;
- (void) autoFocusAtPoint:(CGPoint)point;
- (void) continuousFocusAtPoint:(CGPoint)point;

@end

// These delegate methods can be called on any arbitrary thread. If the delegate does something with the UI when called, make sure to send it to the main thread.
@protocol OFVideoCaptureManagerDelegate <NSObject>
@optional
- (void) captureManager:(OFVideoCaptureManager *)captureManager didFailWithError:(NSError *)error;
- (void) captureManagerRecordingBegan:(OFVideoCaptureManager *)captureManager;
- (void) captureManagerRecordingFinished:(OFVideoCaptureManager *)captureManager;
- (void) captureManagerStillImageCaptured:(OFVideoCaptureManager *)captureManager;
- (void) captureManagerDeviceConfigurationChanged:(OFVideoCaptureManager *)captureManager;
@end
