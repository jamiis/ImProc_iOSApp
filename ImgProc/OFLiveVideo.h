//
//  OFLiveVideo.h
//  ImgProc
//
//  Created by Jamis Johnson on 3/20/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class OFLiveVideo;

@protocol OFLiveVideoDelegate <NSObject>
@required
- (void)setNewFilteredImage:(UIImage *)image;
@end

@interface OFLiveVideo : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate> {
    id <OFLiveVideoDelegate> _delegate;
    AVCaptureSession *_session;
    BOOL _paused;
}

@property (nonatomic, retain) id <OFLiveVideoDelegate> delegate;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, getter=isPaused) BOOL paused;

- (void)setupCaptureSession;

@end
