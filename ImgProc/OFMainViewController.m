//
//  AlgorithmSelectorScrollViewController.m
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFMainViewController.h"
#import "OFHelperFunctions.h"
#import "ImageConverter.h"
#import "ImProc_Base.h"
#import "ImProc_Edges.h"
#import "ImProc_Filters.h"
#import "UIImage-Extensions.h"

@interface OFMainViewController () {
    UIActionSheet *_photoAS;
    UIActionSheet *_actionAS;
    UIPopoverController *_popoverController;
}
- (BOOL)dismissPhotoAS;
- (BOOL)dismissActionAS;
- (BOOL)dismissPopoverController;
- (void)presentInstructionViewWithTag:(NSInteger)tag;
@end


@implementation OFMainViewController

@synthesize scrollViewController  = _scrollViewController,
            photoView             = _photoView,
            liveVideoController   = _liveVideoController,
            algorithmControlsView = _algorithmControlsView, 
            algorithmHandler      = _algorithmHandler,
            instructionImageView  = _instructionImageView, 
            navigationController  = _navigationController;


#pragma mark - View lifecycle
- (void)loadView
{
    [super loadView];
    
    // SCROLL VIEW - holds the algorithm buttons
    _scrollViewController = [[OFAlgorithmScrollViewController alloc] init];
    [_scrollViewController setDelegate:self];
    [self.view addSubview:_scrollViewController.view];
    
    
    // NAVIGATION CONTROLLER
//    _navigationController = [[UINavigationController alloc] init];
//    [_navigationController setDelegate:self];
//    [self.view addSubview:_navigationController.view];
//    _navigationController.view.frame = CGRectMake(0, 0, 768.0, 44.0);
//    [_navigationController.navigationBar setTitle:@"Test"];
//    [_navigationController.navigationBar setTintColor:[UIColor blackColor]];
//    _navigationController.navigationBar setAlpha:<#(CGFloat)#>
    
    
    // NAVIGATION BAR BUTTONS
    // button on NavigationBar to take/upload a photo/video
    UIBarButtonItem *photoSelectionButton = [[UIBarButtonItem alloc] 
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCamera 
                                                                                          target:self
                                                                                    action:@selector(openPhotoAS:)];
//    _navigationController.navigationItem.leftBarButtonItem = photoSelectionButton;
    self.navigationItem.leftBarButtonItem = photoSelectionButton;
    [photoSelectionButton release];
    
    // 'action' button on right side of NavigationBar to perform action 
    // (e.g. save photo to library, post to facebook, etc.)
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                  target:self 
                                                                                  action:@selector(openActionAS:)];
//    _navigationController.navigationItem.rightBarButtonItem = actionButton;
    self.navigationItem.rightBarButtonItem = actionButton;
    [actionButton release];
    
    
    // PHOTOVIEW -- HOLDS PHOTO BEING EDITED
    // allocate a custom UIView for _photoView, the holder of the photo being processed
    _photoView = [[OFPhotoView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:_photoView];
    
    // ALGORITHM CONTROLS -- Initially hidden
    _algorithmControlsView = [[OFAlgorithmControlsView alloc] 
                              initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, ALGORITHM_VIEW_HEIGHT)];
    [_algorithmControlsView setDelegate:self];
    [self.view addSubview:_algorithmControlsView];
    
    // INSTRUCTION OVERLAY
    _instructionImageView = [[OFInstructionImageView alloc] initWithFrame:self.view.frame];
    [_instructionImageView setDelegate:self];
    [self.view addSubview:_instructionImageView];
    [self.view sendSubviewToBack:_instructionImageView];
    
    
    // SETUP TOUCH INPUT
    UIPanGestureRecognizer* panRecognizer = [[[UIPanGestureRecognizer alloc] 
                                              initWithTarget:self action:@selector(adjustAlgorithmInputs:)] autorelease];
    //[panRecognizer setDelegate:self];
    [panRecognizer setMaximumNumberOfTouches:1];
    [panRecognizer setMinimumNumberOfTouches:1];
    [self.view addGestureRecognizer:panRecognizer];
    
    
    // SETUP ALGORITHM HANDLER
    _algorithmHandler = [[OFAlgorithmHandler alloc] init];
    _algorithmHandler.delegate = self;
    [_algorithmHandler setCurrentAlgorithm:ALGORITHM_NONE];
    
    
    // finally, set the background color of the view
    self.view.backgroundColor = [UIColor clearColor];
}


- (void)viewDidLoad
{
    CGRect bounds = self.view.bounds;
    
    // SCROLL VIEW
    //TODO:!!! change this
    [_scrollViewController resizeInFrame:bounds];
    
    // SETUP LIVE VIDEO
    _liveVideoController = [[OFLiveVideoHandler alloc] init];
    [_liveVideoController setDelegate:self];
    
	// Keep track of changes to the device orientation so we can update the video processor
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    // Setup and start the capture session
    [_liveVideoController setupAndStartCaptureSession];
    //[_liveVideoController pauseCaptureSession];
    
    // LABELS
 	shouldShowStats = YES;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        algorithmConstantLabel = [self labelWithText:@"" xPosition:(CGFloat)20.0];
        [algorithmConstantLabel setFont:[UIFont systemFontOfSize:46]];
        
        frameRateLabel = [self labelWithText:@"" xPosition:(CGFloat)548.0];
        [frameRateLabel setFont:[UIFont systemFontOfSize:46]];
    }
    else {
        algorithmConstantLabel = [self labelWithText:@"" xPosition:(CGFloat)10.0];
        [algorithmConstantLabel setFont:[UIFont systemFontOfSize:30]];
        
        frameRateLabel = [self labelWithText:@"" xPosition:(CGFloat)110.0];
        [frameRateLabel setFont:[UIFont systemFontOfSize:30]];
    }
    [algorithmConstantLabel setTextAlignment:UITextAlignmentLeft];
    [frameRateLabel setTextAlignment:UITextAlignmentRight];
    [self.view addSubview:algorithmConstantLabel];
	[self.view addSubview:frameRateLabel];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setTitle:@"ScIP"];
    
    // make sure the status bar isn't showing
    [OFHelperFunctions hideStatusBar];
    
    // bounds of the view. note: self.view.bounds is not correct until this point. it changes after viewDidLoad:
    CGRect bounds = self.view.bounds;
    
    // PHOTO VIEW
    [_photoView resizeGivenBounds:bounds];
    _photoView.backgroundColor = [UIColor clearColor];
    
    // set the photoView's originalImage to our example image
    if (_photoView.originalImageView.image == nil) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_algorithmHandler processImage:[UIImage imageNamed:@"toms.png"]];
        } else {
            [_algorithmHandler processImage:[UIImage imageNamed:@"cassius.png"]];
        }
    }
    
    // TIMER TO UPDATE LABELS
    timer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(updateLabels) userInfo:nil repeats:YES];
}


- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [timer invalidate];
	timer = nil;
}


- (void)cleanup
{
    algorithmConstantLabel = nil;
    frameRateLabel = nil;
	
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    //    [notificationCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    
    // Stop and tear down the capture session
	[_liveVideoController stopAndTearDownCaptureSession];
	[_liveVideoController setDelegate:nil];
    [_liveVideoController release];
}


- (void)viewDidUnload 
{
	[super viewDidUnload];
    
	[self cleanup];
}


- (void)dealloc
{	
    [self cleanup];
    
	[_photoView release];
    [_liveVideoController release];
    [_algorithmControlsView release];
    [_algorithmHandler release];
    [_instructionImageView release];
	
	[super dealloc];
}




#pragma mark - NSNotificationCenter methods
// UIDeviceOrientationDidChangeNotification selector
- (void)deviceOrientationDidChange
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	// Don't update the reference orientation when the device orientation is face up/down or unknown.
	if ( UIDeviceOrientationIsPortrait(orientation) || UIDeviceOrientationIsLandscape(orientation) )
		[_liveVideoController setReferenceOrientation:orientation];
}




#pragma mark - Labels methods
- (void)updateLabels
{
    // if live video is running and shouldShowStats, display FPS
    if ( [_liveVideoController isSessionRunning] && shouldShowStats ) {
        NSString *frameRateString = [NSString stringWithFormat:@"%.1f FPS ", [_liveVideoController videoFrameRate]];
        frameRateLabel.text = frameRateString;
    }
    else {
        frameRateLabel.text = @"";
    }
    
    // if we are in the algorithm view and shouldShowStats is true, display the algorithm input
    if ( [_photoView isInAlgorithmView] && shouldShowStats && 
        ![self isNonAdjustableAlgorithm:[_algorithmHandler getCurrentAlgorithm]]) 
    {
        NSString *algorithmConstantString = [NSString stringWithFormat:@"%i Input", [_algorithmHandler getCurrentAlpha]];
        algorithmConstantLabel.text = algorithmConstantString;
    }
    else {
        algorithmConstantLabel.text = @"";
    }
}


- (BOOL)isNonAdjustableAlgorithm:(NSInteger)algorithm
{
    if (algorithm == ALGORITHM_INVERT || 
        algorithm == ALGORITHM_GAUSSIAN_BLUR ||
        algorithm == ALGORITHM_FAST_SHARPEN ||
        algorithm == ALGORITHM_STATIC ||
        algorithm == ALGORITHM_ERODE ||
        algorithm == ALGORITHM_DILATE ||
        algorithm == ALGORITHM_NOISE_REDUCTION ||
        algorithm == ALGORITHM_GRADIENT_MAGNITUDE) {
        return YES;
    }
    else {
        return NO;
    }
}


- (UILabel *)labelWithText:(NSString *)text xPosition:(CGFloat)xPosition
{
    CGFloat yPosition;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        yPosition = self.view.bounds.size.height - SCROLLVIEW_HEIGHT_IPAD - 34;
    else
        yPosition = self.view.bounds.size.height - SCROLLVIEW_HEIGHT - 44;
    
	CGFloat labelWidth = 200.0;
	CGFloat labelHeight = 40.0;
//	CGFloat xPosition = self.view.bounds.size.width - labelWidth - 10;
	CGRect labelFrame = CGRectMake(xPosition, yPosition, labelWidth, labelHeight);
	UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
	[label setLineBreakMode:UILineBreakModeWordWrap];
	[label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
//	[label setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25]];
	[[label layer] setCornerRadius: 4];
	[label setText:text];
    
	return [label autorelease];
}




#pragma mark - Animations
- (void)viewDidLayoutSubviews
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // animate to algorithm view
        if (_photoView.isInAlgorithmView) 
        {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            frameRateLabel.hidden = NO;
            algorithmConstantLabel.hidden = NO;
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            //[self.view bringSubviewToFront:_algorithmControlsView];
            
            _algorithmControlsView.frame                  = FRAME_ALGORITHMS_VIEW_IPAD_ALGORITHM_CONTROLS;
            _scrollViewController.view.frame              = FRAME_ALGORITHMS_VIEW_IPAD_SCROLL_VIEW;
//            self.navigationController.navigationBar.frame = FRAME_ALGORITHMS_VIEW_IPAD_NAV_BAR;
            
            // adjust the photoview to be center with the app's main window
            //[_photoView animateToAlgorithmViewGivenBounds:bounds];
            
            [UIView commitAnimations];
        }
        
        // animate to main view
        else if (!_photoView.isInAlgorithmView) {  
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            frameRateLabel.hidden = YES;
            algorithmConstantLabel.hidden = YES;
            
            // animate back to main view
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            _algorithmControlsView.frame                  = FRAME_MAIN_VIEW_IPAD_ALGORITHM_CONTROLS;
            _scrollViewController.view.frame              = FRAME_MAIN_VIEW_IPAD_SCROLL_VIEW;
//            self.navigationController.navigationBar.frame = FRAME_MAIN_VIEW_IPAD_NAV_BAR;
            
            // adjust the photoview to be center with the app's main window
            //[_photoView animateToMainViewGivenBounds:bounds];
            
            [UIView commitAnimations];
        }
    }
    else {
        // animate to algorithm view
        if (_photoView.isInAlgorithmView) 
        {
            self.navigationItem.leftBarButtonItem.enabled = NO;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            
            frameRateLabel.hidden = NO;
            algorithmConstantLabel.hidden = NO;
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            //[self.view bringSubviewToFront:_algorithmControlsView];
            
            _algorithmControlsView.frame                  = FRAME_ALGORITHMS_VIEW_IPHONE_ALGORITHM_CONTROLS;
            _scrollViewController.view.frame              = FRAME_ALGORITHMS_VIEW_IPHONE_SCROLL_VIEW;
//            self.navigationController.navigationBar.frame = FRAME_ALGORITHMS_VIEW_IPHONE_NAV_BAR;

            // adjust the photoview to be center with the app's main window
            //[_photoView animateToAlgorithmViewGivenBounds:bounds];
            
            [UIView commitAnimations];
        }
        
        // animate to main view
        else if (!_photoView.isInAlgorithmView) {
            self.navigationItem.leftBarButtonItem.enabled = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
            
            frameRateLabel.hidden = YES;
            algorithmConstantLabel.hidden = YES;
            
            // animate back to main view
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            _algorithmControlsView.frame                  = FRAME_MAIN_VIEW_IPHONE_ALGORITHM_CONTROLS;
            _scrollViewController.view.frame              = FRAME_MAIN_VIEW_IPHONE_SCROLL_VIEW;
//            self.navigationController.navigationBar.frame = FRAME_MAIN_VIEW_IPHONE_NAV_BAR;

            // adjust the photoview to be center with the app's main window
            //[_photoView animateToMainViewGivenBounds:bounds];
            
            [UIView commitAnimations];
        }
    }
}


- (void) animateToAlgorithmViewWithTag:(int)tag
{
    _photoView.isInAlgorithmView = TRUE;
    [self.view setNeedsLayout];
}


- (void) animateToMainViewWithTag:(int)tag
{
    _photoView.isInAlgorithmView = FALSE;
    [self.view setNeedsLayout];
}




#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





#pragma mark - OFAlgorithmHandlerDelegate Methods
- (void)setOriginalImage:(UIImage*)image 
{ 
    [_photoView setOriginalImage:image];
}


- (void)setEditedImage:(UIImage*)image
{ 
    [_photoView setEditedImage:image];

    //    UIImagePNGRepresentation(<#UIImage *image#>)
    
    // if we are recording, add this frame to the movieArray
    // to be recorded to a movie after the recording is done
//    if (_algorithmHandler.liveVideoIsRecording) {
//        [_movieArray addObject:image.copy];
//        [_movieArray addObject:[image.copy imageRotatedByDegrees:-90]];
//    }
}




#pragma mark - OFLiveVideoDelegate Methods
- (void)setNewFilteredImage:(UIImage *)image
{
    if (_algorithmHandler.algorithm.currentAlgorithm == ALGORITHM_NONE) {
        [_photoView setOriginalImage:image];
    }
    else {
        [_photoView setEditedImage:image];
    }
}


- (void)processPixelBuffer:(CVImageBufferRef)pixelBuffer
{
    [_algorithmHandler processPixelBuffer:pixelBuffer];
}


- (void)recordingWillStart
{
    NSLog(@"mvc: recordingWillStart");
	dispatch_async(dispatch_get_main_queue(), ^{
        //TODO: FIGURE OUT SETTING TITLE AND ENABLING AND DISABLING
        [_algorithmControlsView.recordVideoButton setEnabled:NO];
        [_algorithmControlsView.recordVideoButton setTitle:@"Stop" forState:UIControlStateNormal];
        
		// Disable the idle timer while we are recording
		[UIApplication sharedApplication].idleTimerDisabled = YES;
        
		// Make sure we have time to finish saving the movie if the app is backgrounded during recording
		if ([[UIDevice currentDevice] isMultitaskingSupported])
			backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	});
}


- (void)recordingDidStart
{
    NSLog(@"mvc: recordingDidStart");
    dispatch_async(dispatch_get_main_queue(), ^{
        [_algorithmControlsView.recordVideoButton setEnabled:YES];
    });
}


- (void)recordingWillStop
{
    NSLog(@"mvc: recordingWillStop");
    dispatch_async(dispatch_get_main_queue(), ^{
        // Disable until saving to the camera roll is complete
        [_algorithmControlsView.recordVideoButton setTitle:@"Record" forState:UIControlStateNormal];
        [_algorithmControlsView.recordVideoButton setEnabled:NO];
        
        // Pause the capture session so that saving will be as fast as possible.
        // We resume the sesssion in recordingDidStop:
        [_liveVideoController pauseCaptureSession];
    });
}

- (void)recordingDidStop
{
    NSLog(@"mvc: recordingDidStop");
	dispatch_async(dispatch_get_main_queue(), ^{
		[_algorithmControlsView.recordVideoButton setEnabled:YES];
		
		[UIApplication sharedApplication].idleTimerDisabled = NO;
        
		[_liveVideoController resumeCaptureSession];
        
		if ([[UIDevice currentDevice] isMultitaskingSupported]) {
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
			backgroundRecordingID = UIBackgroundTaskInvalid;
		}
	});
}




#pragma mark - OFScrollViewControllerDelegate Methods
- (void)scrollViewButtonPressed:(id)sender
{
    // initialize algorithm settings
    UIButton * button = (UIButton *) sender;
    [_algorithmHandler setCurrentAlgorithm:button.tag];
    [_algorithmHandler setInitialAlpha];
    
    // if in live video mode, hide the apply changes button
    if ([_liveVideoController isSessionRunning]) {
        [_algorithmControlsView setInLiveVideoMode:TRUE];
    }
    else if (![_liveVideoController isSessionRunning]) {
        [_algorithmControlsView setInLiveVideoMode:FALSE];
    }
    
    // if the button is not a demo button, animate to algorithm view
    if ([_algorithmHandler getCurrentAlgorithm] != ALGORITHM_DEMO) {
        // animate to the algorithm view
        [self animateToAlgorithmViewWithTag:button.tag];
        // present user instructions
        //[self presentInstructionViewWithTag:button.tag];
    }
    
    // process the image with the selected algorithm
    [_algorithmHandler processImage:_photoView.originalImageView.image];
}



#pragma mark - Instructions methods
- (void)presentInstructionViewWithTag:(NSInteger)tag
{
    // if not in live video, display instructions
//    if (![_liveVideoController isSessionRunning]) {
//        [_instructionImageView setImageWithTag:tag];
//        [self.view bringSubviewToFront:_instructionImageView];
//    }

    [_instructionImageView setImageWithTag:tag];
    [self.view bringSubviewToFront:_instructionImageView];

    
//    UIImageView *instructionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instruction_overlay_ipad.png"]];
//    UIViewController *instructionViewController = [[[UIViewController alloc] init] autorelease];
//    [instructionViewController.view setBackgroundColor:[UIColor clearColor]];
//    [instructionViewController setView:instructionImageView];
//    instructionViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:instructionViewController animated:YES completion:nil];
}


#pragma mark - OFInstructionImageViewDelegate methods
- (void)dismissInstructionImageView
{
    _instructionImageView.image = nil;
    [self.view sendSubviewToBack:_instructionImageView];
}




#pragma mark - OFAlgorithmControlsViewDelegate methods
- (void)algorithmViewBackButtonPressed
{
    // don't change the original image
    [_photoView.editedImageView setImage:NULL];
    [_algorithmHandler setCurrentAlgorithm:ALGORITHM_NONE];
    [self animateToMainViewWithTag:0];
    
    // stop recording
    if ( _liveVideoController.isRecording )
        [_liveVideoController stopRecording];
}


- (void)algorithmViewApplyChangesButtonPressed
{
    // change original image
    [_photoView setOriginalImage:_photoView.editedImageView.image];
    
    [_photoView.editedImageView setImage:NULL];
    [_algorithmHandler setCurrentAlgorithm:ALGORITHM_NONE];
    [self animateToMainViewWithTag:0];
}


- (void)algorithmViewRecordVideoButtonPressed
{
    // Wait for the recording to start/stop before re-enabling the record button.
    [_algorithmControlsView.recordVideoButton setEnabled:NO];
    //[[self recordButton] setEnabled:NO];
    
    if ( [_liveVideoController isRecording] ) {
        // The recordingWill/DidStop delegate methods will fire asynchronously in response to this call
        [_liveVideoController stopRecording];
    }
    else {
        // The recordingWill/DidStart delegate methods will fire asynchronously in response to this call
        [_liveVideoController startRecording];
    }
//    }
//    if (_algorithmHandler.liveVideoIsRunning) {
//        if (!_algorithmHandler.liveVideoIsRecording) {
//            // create new movie array to hold processed UIImages
//            _movieArray = [[NSMutableArray alloc] init];
//            
//            // set recording to true
//            _algorithmHandler.liveVideoIsRecording = YES;
//            NSLog(@"start recording");
//        }
//        else if (_algorithmHandler.liveVideoIsRecording) {
//            // stop recording
//            _algorithmHandler.liveVideoIsRecording = NO;
//            NSLog(@"stop recording");
//            
//            // process movie
//            [self performSelectorInBackground:(@selector(processMovie)) withObject:nil];
//        }
//    }
}


- (void)algorithmViewHelpButtonPressed
{
    [self presentInstructionViewWithTag:[_algorithmHandler getCurrentAlgorithm]];
}


//- (void) processMovie
//{
//    if (_movieArray == nil) {
//        NSLog(@"ERROR: _movieArray was nil when asked to process movie");
//        return;
//    }
//    
//    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//    
//    // first delete all existing content in the temp directory
//    NSString *tempPath = NSTemporaryDirectory();
//    //NSArray *dirContents = [[NSFileManager defaultManager] directoryContentsAtPath:tempPath];
//    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tempPath error:nil];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if (dirContents) {	
//        for (int i = 0; i < [dirContents count]; i++) {
//            NSLog(@"Directory Count: %i", [dirContents count]);
//            NSString *contentsOnly = [NSString stringWithFormat:@"%@%@", tempPath, [dirContents objectAtIndex:i]];
//            [fileManager removeItemAtPath:contentsOnly error:nil];
//        }
//    }
//    
//    // create temporary movie file which will later be put into user's photo album
//
//    NSString *tempFileTemplate = [NSTemporaryDirectory() stringByAppendingPathComponent:@"temprecording.XXXXXXX"];
//    const char *tempFileTemplateCString = [tempFileTemplate fileSystemRepresentation];
//    char *tempFileNameCString = (char *)malloc(strlen(tempFileTemplateCString) + 1);
//    strcpy(tempFileNameCString, tempFileTemplateCString);
//    int fileDescriptor = mkstemp(tempFileNameCString);
//    
//    if (fileDescriptor == -1) {
//        NSLog(@"ERROR: creating temp file for movie recording");
//        return;
//    }
//    
//    // otherwise file opened successfully
//    NSString *tempFilePath = [[NSFileManager defaultManager] stringWithFileSystemRepresentation:tempFileNameCString 
//                                                                                   length:strlen(tempFileNameCString)];
//    tempFilePath = [tempFilePath stringByAppendingPathExtension:@"mp4"];
//    free(tempFileNameCString);
//    //close(fileDescriptor);
//    
//    UIImage *firstMovieFrame = [_movieArray objectAtIndex:0];
//    if (firstMovieFrame.imageOrientation == UIImageOrientationUp)
//        NSLog(@"1st movie frame orientation: %i",firstMovieFrame.imageOrientation);
//    CGSize movieFrameSize = firstMovieFrame.size;
//    [_liveVideoController recordMovieFromImageArray:_movieArray 
//                                             toPath:tempFilePath 
//                                               size:movieFrameSize
//                                           duration:1];
//    
//    if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(tempFilePath))
//    {
//        UISaveVideoAtPathToSavedPhotosAlbum(tempFilePath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//    }
//    
//    [pool drain];
//    _movieArray = nil;
//}

// default function for error checking with 
// UISaveVideoAtPathToSavedPhotosAlbum a few lines above
//- (void)video:(NSString *)videoPath
//didFinishSavingWithError:(NSError *)error
//             contextInfo:(void *)contextInfo 
//{
//    if (error) {
//        NSLog(@"ERROR: saving video to user's library. description: %@", error.description);
//    } else {
//        NSLog(@"whoopeee! we have written a new video!");
//    }
//}




#pragma mark - Touches and Adjusting Algorithm Inputs
- (void)adjustAlgorithmInputs:(id)sender
{
    UIPanGestureRecognizer* panRecognizer = (UIPanGestureRecognizer*) sender;
    
    // if the adjustment has ended, set the previous value to the current
    if ([panRecognizer state] == UIGestureRecognizerStateEnded)
    {
        [_algorithmHandler finishedAdjustingAlgorithmAlpha];
        return;
    }
    
    if ([panRecognizer state] == UIGestureRecognizerStateChanged && 
        _photoView.isInAlgorithmView &&
        [_algorithmHandler getCurrentAlgorithm] != ALGORITHM_NONE &&
        [_algorithmHandler getCurrentAlgorithm] != ALGORITHM_INVERT &&
        [_algorithmHandler getCurrentAlgorithm] != ALGORITHM_GRADIENT_MAGNITUDE &&
        [_algorithmHandler getCurrentAlgorithm] != ALGORITHM_ERODE &&
        [_algorithmHandler getCurrentAlgorithm] != ALGORITHM_DILATE &&
        [_algorithmHandler getCurrentAlgorithm] != ALGORITHM_NOISE_REDUCTION) 
    {
        // change alpha value that goes into the algorithm
        // then reprocess the image
        CGPoint translatedPoint = [panRecognizer translationInView:self.view];
        [_algorithmHandler adjustAlgorithmAlpha:translatedPoint.x];
        if (!_algorithmHandler.liveVideoIsRunning) {
            [_algorithmHandler processImage:_photoView.originalImageView.image];
        }
    }
}




#pragma mark - UIPopoverController Methods
- (BOOL)dismissPopoverController
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
        _popoverController != nil) 
    {
        [_popoverController dismissPopoverAnimated:TRUE];
        _popoverController = nil;
        return TRUE;
    }
    return FALSE;
}




#pragma mark - Photo ActionSheet (UIActionSheetDelegate)
- (void)openPhotoAS:(id)sender
{
    if (!_photoView.isInAlgorithmView) 
    {
        // if the photoAS is displayed and the Open Image tabbar button is pressed again
        if ([self dismissPhotoAS]) { return; }
        [self dismissActionAS];
        
        // dismiss popover, but don't return
        if ([self dismissPopoverController]) { return; }
        
        // get the correct string for Live Video
        NSString * liveVideoString;
        if     (![_liveVideoController isSessionRunning]) liveVideoString = @"Start Live Video";
        else if ([_liveVideoController isSessionRunning]) liveVideoString = @"Stop Live Video";
        else NSLog(@"liveVideoController.session is neither running nor not running - attempting to assign action sheet string");
        
        // create an action sheet for buttons to camera functionality
        _photoAS = [[UIActionSheet alloc] initWithTitle:@""
                                               delegate:self 
                                      cancelButtonTitle:@"Cancel"
                                 destructiveButtonTitle:nil
                                      otherButtonTitles:@"Take a Photo",@"Photo Library",liveVideoString,nil,nil];

        // tag so actionSheet:clickedButtonAtIndex: can identify correctly
        _photoAS.tag = 0;
        _photoAS.actionSheetStyle = (UIActionSheetStyle) self.navigationController.navigationBar.barStyle;
        
        // depending on the device, adjust how action sheet is displayed
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_photoAS showFromBarButtonItem:self.navigationItem.leftBarButtonItem animated:TRUE];
        }
        else {
            [_photoAS showInView:self.view];
        }
        
        [_photoAS release];
    }
}


- (BOOL)dismissPhotoAS
{
    if (_photoAS != nil) {
        [_photoAS dismissWithClickedButtonIndex:0 animated:TRUE];
        _photoAS = nil;
        return TRUE;
    }
    
    return FALSE;
}


#pragma mark - Action ActionSheet
- (void)openActionAS:(id)sender
{
    if (!_photoView.isInAlgorithmView) 
    {
        // if the photoAS is displayed and the Open Image tabbar button is pressed again
        if ([self dismissActionAS]) { return; }
        [self dismissPhotoAS];
        
        // dismiss popover, but don't return
        if ([self dismissPopoverController]) { return; }
        
        _actionAS = [[UIActionSheet alloc] initWithTitle:@""
                                                delegate:self 
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                       otherButtonTitles:@"Save Photo to Library",
                     //@"Share on Facebook",
                     nil,nil];
        
        // tag so actionSheet:clickedButtonAtIndex: can identify correctly
        _actionAS.tag = 1;
        _actionAS.actionSheetStyle = (UIActionSheetStyle) self.navigationController.navigationBar.barStyle;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [_actionAS showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:TRUE];
        }
        else {
            [_actionAS showInView:self.view];   
        }
        
        [_actionAS release];
    }
}


- (BOOL)dismissActionAS
{
    if (_actionAS != nil) {
        [_actionAS dismissWithClickedButtonIndex:0 animated:TRUE];
        _actionAS = nil;
        return TRUE;
    }
    
    return FALSE;
}




#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // if opening a photo or video
    if (modalView.tag == 0)
    {
        [self dismissPhotoAS]; // always dismiss the AS
        
        switch (buttonIndex)
        {
            case 0:
            {
                [self startCameraControllerFromViewController:self 
                                                usingDelegate:self];
                break;
            }
            case 1:
            {
                [self startMediaBrowserFromViewController:self
                                            usingDelegate:self];
                break;
            }
            case 2:
            {
                if (![_liveVideoController isSessionRunning]) {
                    [_liveVideoController resumeCaptureSession];
                    //TODO: REMOVE _algorithmH.liveVideoIsRunning var
                    _algorithmHandler.liveVideoIsRunning = TRUE;
                }
                else if ([_liveVideoController isSessionRunning]) {
                    [_liveVideoController pauseCaptureSession];
                    //TODO: REMOVE _algorithmH.liveVideoIsRunning var
                    _algorithmHandler.liveVideoIsRunning = FALSE;
                }
                else {
                    NSLog(@"liveVideoController.session is neither running nor not running");
                }
                //[self startMovieControllerFromViewController:self usingDelegate:self];
                break;
            }
        }
    }
    
    // if top-right action button on the uinavigationbar was selected
    else if (modalView.tag == 1)
    {
        [self dismissActionAS];
        
        switch (buttonIndex)
        {
            case 0:
            {
                if (!_algorithmHandler.liveVideoIsRunning) {
                    UIImageWriteToSavedPhotosAlbum(_photoView.originalImageView.image, nil, nil, nil);
                }
                break;
            }
//            case 1:
//            {
//                NSLog(@"Share with Facebook!");
//                break;
//            }
        }
    }
    
    // hide the status bar. might not be necessary but just to be safe:
    [OFHelperFunctions hideStatusBar];
}




#pragma mark - Photo and Video ActionSheet Button Functionality
- (BOOL)startCameraControllerFromViewController: (UIViewController*) controller
                                  usingDelegate: (id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>) delegate 
{
    if ([_liveVideoController isSessionRunning]) {
        [_liveVideoController pauseCaptureSession];
        // TODO: REMOVE THIS BELOW
        _algorithmHandler.liveVideoIsRunning = FALSE;
        _liveVideoController.paused = YES;
    }
    
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    
    //cameraUI.mediaTypes =
    //[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}


- (BOOL)startMovieControllerFromViewController:(UIViewController*) controller
                                 usingDelegate:(id <UIImagePickerControllerDelegate,
                                                UINavigationControllerDelegate>) delegate 
{
    if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
        
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController:cameraUI animated: YES];
        
    return YES;
}


- (BOOL)startMediaBrowserFromViewController:(UIViewController*) controller
                              usingDelegate:(id <UIImagePickerControllerDelegate,
                                             UINavigationControllerDelegate>) delegate {
    
    // dismiss popover, but don't return
    [self dismissPopoverController];
    
    if ([_liveVideoController isSessionRunning]) 
    {
        [_liveVideoController pauseCaptureSession];
        _algorithmHandler.liveVideoIsRunning = FALSE;
        _liveVideoController.paused = YES;
    }
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
    UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    
    mediaUI.delegate = delegate;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:mediaUI];
        [_popoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem 
                                        permittedArrowDirections:UIPopoverArrowDirectionUp 
                                                        animated:TRUE];
    }
    else {
        [controller presentModalViewController:mediaUI animated: YES];
    }

    return YES;
}




#pragma mark - UIImagePickerControllerDelegate methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // dismiss popovercontroller that handles picking a photo
    [self dismissPopoverController];
    
    // stop the live video session
    if ([_liveVideoController isSessionRunning]) {
        [_liveVideoController pauseCaptureSession];
        _algorithmHandler.liveVideoIsRunning = FALSE;
    }
    
    if ([_liveVideoController isPaused]) {
        _liveVideoController.paused = NO;
    }
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image taken with camera or picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage   = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // adjust picture scale depending on which camera is being used
            float scale = 1.0;
            if (picker.cameraDevice == UIImagePickerControllerCameraDeviceRear)
                scale = PHOTOVIEW_REAR_CAMERA_SCALE;
            else if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
                scale = PHOTOVIEW_FRONT_CAMERA_SCALE;
        
            UIImageOrientation photoOrientation;
            // grab either the editedImage or originalImage
            if (editedImage) {
                imageToUse = [UIImage imageWithCGImage:[editedImage CGImage] scale:scale orientation:UIImageOrientationUp];
                photoOrientation = editedImage.imageOrientation;
            } else {
                imageToUse = [UIImage imageWithCGImage:[originalImage CGImage] scale:scale orientation:UIImageOrientationUp];
                photoOrientation = originalImage.imageOrientation;
            }
                
            // set imageToUse as our photo
            if (photoOrientation == UIImageOrientationUp) {
                [_algorithmHandler processImage:[imageToUse imageRotatedByDegrees:0.0]];
            }
            else if (photoOrientation == UIImageOrientationRight) {
                [_algorithmHandler processImage:[imageToUse imageRotatedByDegrees:90.0]];
            }
            else if (photoOrientation == UIImageOrientationDown) {
                [_algorithmHandler processImage:[imageToUse imageRotatedByDegrees:180.0]];
            }
            else if (photoOrientation == UIImageOrientationLeft) {
                [_algorithmHandler processImage:[imageToUse imageRotatedByDegrees:270.0]];
            }
            else {
                NSLog(@"FAIL: the photo doesn't have an orientation!");
            }
        }
        
        else if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary ||
            picker.sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) 
        {
            if (editedImage) {
                imageToUse = editedImage;
            } else {
                imageToUse = originalImage;
            }
            [_algorithmHandler processImage:imageToUse];
        }
        
        // dismiss the the modal view
        [self dismissModalViewControllerAnimated: YES];
        [picker release];
    }
    
    // TODO: Handle a movie picked from a photo album
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        // NSLog(@"You have recorded a video.");
        
        //NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        // Do something with the picked movie available at moviePath
    }
}


// For responding to the user tapping Cancel whether in the camera or photo library.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker 
{
    // if the live video was running before taking/uploading a photo (aka "paused"), restart
    if ([_liveVideoController isPaused]) {
        [_liveVideoController resumeCaptureSession];
        _algorithmHandler.liveVideoIsRunning = TRUE;
        _liveVideoController.paused = NO;
    }

    [self dismissModalViewControllerAnimated: YES];
    [picker release];
    
    // hide status bar again
    [OFHelperFunctions hideStatusBar];
}




#pragma mark - Helper Functions
// simple helper function to print the contents of a frame combined with some prefix
- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix
{
    NSString* printStr = [prefix stringByAppendingString:@" ==> x: %3.2f, y: %3.2f, w: %3.2f, h: %3.2f"];
    CGPoint origOrig = rect.origin;
    CGSize  origSize = rect.size;
    NSLog(printStr, origOrig.x, origOrig.y, origSize.width, origSize.height);
}


@end
