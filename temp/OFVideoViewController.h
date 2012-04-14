//
//  OFVideoViewController.h
//  ImgProc
//
//  Created by Jamis Johnson on 3/19/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OFVideoCaptureManager, AVCamPreviewView, AVCaptureVideoPreviewLayer;

@interface OFVideoViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
}

@property (nonatomic,retain) OFVideoCaptureManager *captureManager;
@property (nonatomic,retain) UIView *videoPreviewView;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic,retain) UIButton *cameraToggleButton;
@property (nonatomic,retain) UIButton *recordButton;
@property (nonatomic,retain) UIButton *stillButton;
@property (nonatomic,retain) UILabel *focusModeLabel;

#pragma mark Toolbar Actions
- (IBAction)toggleRecording:(id)sender;
- (IBAction)captureStillImage:(id)sender;
- (IBAction)toggleCamera:(id)sender;

@end

