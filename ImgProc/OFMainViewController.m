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
    UIPopoverController *_photoPopoverController;
}
- (BOOL)dismissPhotoAS;
- (BOOL)dismissPhotoPopoverController;
@end


@implementation OFMainViewController

@synthesize scrollViewController  = _scrollViewController,
            photoView             = _photoView,
            liveVideoController   = _liveVideoController,
            algorithmControlsView = _algorithmControlsView, 
            algorithmHandler      = _algorithmHandler;


#pragma mark - View lifecycle
- (void)loadView
{
    [super loadView];
    
    // SCROLL VIEW - holds the algorithm buttons
    _scrollViewController = [[OFAlgorithmScrollViewController alloc] init];
    [_scrollViewController setDelegate:self];
    [self.view addSubview:_scrollViewController.view];
    
    
    // NAVIGATION BAR BUTTONS
    // button on NavigationBar to take/upload a photo/video
    UIBarButtonItem *photoSelectionButton = [[UIBarButtonItem alloc] 
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCamera 
                                                                                          target:self
                                                                                    action:@selector(openPhotoAS:)];
    self.navigationItem.leftBarButtonItem = photoSelectionButton;
    [photoSelectionButton release];
    
    // 'action' button on right side of NavigationBar to perform action 
    // (e.g. save photo to library, post to facebook, etc.)
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                                  target:self 
                                                                                  action:@selector(openActionAS:)];
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
    
    
    // SETUP LIVE VIDEO
    _liveVideoController = [[OFLiveVideo alloc] init];
    [_liveVideoController setDelegate:self];
    [_liveVideoController setupCaptureSession];
    
    
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // make sure the status bar isn't showing
    [OFHelperFunctions hideStatusBar];
    
    // bounds of the view. note: self.view.bounds is not correct until this point. it changes after viewDidLoad:
    CGRect bounds = self.view.bounds;
    
    // SCROLL VIEW
    // TODO: adapt for ipad and rotated views!!
    [_scrollViewController resizeInFrame:bounds];
    
    // PHOTO VIEW
    [_photoView resizeGivenBounds:bounds];
    _photoView.backgroundColor = [UIColor clearColor];
    
    // set the photoView's originalImage to our example image
    if (_photoView.originalImageView.image == nil) {
        [_algorithmHandler processImage:[UIImage imageNamed:@"cassius.jpg"]];
    }
}


- (void)dealloc
{	
	[_photoView release];
    [_liveVideoController release];
    [_algorithmControlsView release];
    [_algorithmHandler release];
	
	[super dealloc];
}




#pragma mark - Rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait ||
            interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    NSLog(@"willAnimateRotationToInterfaceOrientation");    
}




#pragma mark - OFAlgorithmHandlerDelegate Methods
- (void)setOriginalImage:(UIImage*)image { [_photoView setOriginalImage:image]; }
- (void)setEditedImage:(UIImage*)image   { [_photoView setEditedImage:image]; }




#pragma mark - OFLiveVideoDelegate Methods
- (void)setNewFilteredImage:(UIImage *)image { [_algorithmHandler processImage:[image imageRotatedByDegrees:90.0]]; }




#pragma mark - OFScrollViewControllerDelegate Methods
- (void)scrollViewButtonPressed:(id)sender
{
    // initialize algorithm settings
    UIButton * button = (UIButton *) sender;
    [_algorithmHandler setCurrentAlgorithm:button.tag];
    [_algorithmHandler setInitialAlpha];
    
    // if in live video mode, hide the apply changes button
    if (_liveVideoController.session.running) {
        _algorithmControlsView.applyChangesButton.hidden = YES;
    }
    else if (!_liveVideoController.session.running) {
        _algorithmControlsView.applyChangesButton.hidden = NO;
    }
    
    // if the button is not a demo button, animate to algorithm view
    if ([_algorithmHandler getCurrentAlgorithm] < ALGORITHM_DEMO) {
        [self animateToAlgorithmViewWithTag:button.tag];
    }
    
    // process the image with the selected algorithm
    [_algorithmHandler processImage:_photoView.originalImageView.image];
}




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
    
    if ([panRecognizer state] == UIGestureRecognizerStateChanged || 
        _photoView.isInAlgorithmView ||
        [_algorithmHandler getCurrentAlgorithm] != ALGORITHM_INVERT ||
        [_algorithmHandler getCurrentAlgorithm] != ALGORITHM_NONE) 
    {
        // change alpha value that goes into the algorithm
        // then reprocess the image
        CGPoint translatedPoint = [panRecognizer translationInView:self.view];
        [_algorithmHandler adjustAlgorithmAlpha:translatedPoint.x];
        [_algorithmHandler processImage:_photoView.originalImageView.image];
    }
}




#pragma mark - Animations
- (void) animateToAlgorithmViewWithTag:(int)tag
{
    CGRect bounds = self.view.bounds;
    
    // set the photoView to be touchable
    _photoView.isInAlgorithmView = TRUE;
    
    // BEGIN ANIMATION
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // ALGORITHM CONTROLS
    [self.view bringSubviewToFront:_algorithmControlsView];
    float f_y = bounds.size.height - ALGORITHM_VIEW_HEIGHT;
    _algorithmControlsView.frame = CGRectMake(0.0, f_y, bounds.size.width, ALGORITHM_VIEW_HEIGHT);
        
    // SCROLLVIEW
    [_scrollViewController animateViewOnScreen];
    
    // NAVIGATION BAR
    CGRect navFrame = self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(navFrame.origin.x, 
                                                               navFrame.origin.y - navFrame.size.height,
                                                               navFrame.size.width,
                                                               navFrame.size.height);
    // PHOTOVIEW
    [_photoView animateToAlgorithmViewGivenBounds:bounds];
    
    [UIView commitAnimations];
}


- (void) animateToMainViewWithTag:(int)tag
{
    CGRect bounds = self.view.bounds;
    
    // set photoView to not except touches
    _photoView.isInAlgorithmView = FALSE;
    
    // animate back to main view
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // ALGORITHM CONTROLS
    _algorithmControlsView.frame = CGRectMake(0.0, bounds.size.height, bounds.size.width, ALGORITHM_VIEW_HEIGHT);
    
    // SCROLLVIEW
    [_scrollViewController animateViewOffScreen];
    
    // NAVIGATION BAR
    CGRect navFrame = self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(navFrame.origin.x, 
                                                               navFrame.origin.y + navFrame.size.height,
                                                               navFrame.size.width,
                                                               navFrame.size.height);
    // PHOTOVIEW
    // adjust the photoview to be center with the app's main window
    [_photoView animateToMainViewGivenBounds:bounds];
    
    //NSLog(@"animating to main view");
    [UIView commitAnimations];
}




#pragma mark - OFAlgorithmViewDelegate methods
- (void)algorithmViewBackButtonPressed
{
    // don't change the original image
    [_algorithmHandler setCurrentAlgorithm:ALGORITHM_NONE];
    _photoView.editedImageView.image = NULL;
    [self animateToMainViewWithTag:0];
}


- (void)algorithmViewApplyChangesButtonPressed
{
    // change original image
    [_photoView setOriginalImage:_photoView.editedImageView.image];
    _photoView.editedImageView.image = NULL;
    [_algorithmHandler setCurrentAlgorithm:ALGORITHM_NONE];
    [self animateToMainViewWithTag:0];
}




#pragma mark - NavBar and Action Sheet Methods (UIActionSheetDelegate)
- (void)openPhotoAS:(id)sender
{
    // if the photoAS is displayed and the Open Image tabbar button is pressed again
    if ([self dismissPhotoAS]) { return; }
    
    // dismiss popover, but don't return
    if ([self dismissPhotoPopoverController]) { return; }
    
    // get the correct string for Live Video
	NSString * liveVideoString;
    if (!_liveVideoController.session.running) {
        liveVideoString = @"Start Live Video";
    }
    else if (_liveVideoController.session.running) {
        liveVideoString = @"Stop Live Video";
    }
    else {
        NSLog(@"liveVideoController.session is neither running nor not running - attempting to assign action sheet string");
    }
    
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


- (BOOL)dismissPhotoAS
{
    if (_photoAS != nil) {
        [_photoAS dismissWithClickedButtonIndex:0 animated:TRUE];
        _photoAS = nil;
        return TRUE;
    }
    
    return FALSE;
}


- (BOOL)dismissPhotoPopoverController
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad &&
        _photoPopoverController != nil) 
    {
        [_photoPopoverController dismissPopoverAnimated:TRUE];
        _photoPopoverController = nil;
        return TRUE;
    }
    
    return FALSE;
}


- (void)openActionAS:(id)sender
{
    UIActionSheet *actionAS = [[UIActionSheet alloc] initWithTitle:@""
                                                         delegate:self 
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"Save Photo to Library",@"Share on Facebook",nil,nil];
    
    // tag so actionSheet:clickedButtonAtIndex: can identify correctly
    actionAS.tag = 1;
    actionAS.actionSheetStyle = (UIActionSheetStyle) self.navigationController.navigationBar.barStyle;
	
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [actionAS showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:TRUE];
    }
    else {
        [actionAS showInView:self.view];   
    }
    
    [actionAS release];
}


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
                if (!_liveVideoController.session.running) {
                    [_liveVideoController.session startRunning];
                    _algorithmHandler.liveVideoIsRunning = TRUE;
                }
                else if (_liveVideoController.session.running) {
                    [_liveVideoController.session stopRunning];
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
        switch (buttonIndex)
        {
            case 0:
            {
                NSLog(@"Save to Photo Library!");
                break;
            }
            case 1:
            {
                NSLog(@"Share with Facebook!");
                break;
            }
        }
    }
    
    // hide the status bar. might not be necessary but just to be safe:
    [OFHelperFunctions hideStatusBar];
}



#pragma mark - Photo and Video Action Sheet Button Functionality
- (BOOL)startCameraControllerFromViewController: (UIViewController*) controller
                                  usingDelegate: (id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>) delegate 
{
    if (_liveVideoController.session.running) {
        [_liveVideoController.session stopRunning];
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
    [self dismissPhotoPopoverController];
    
    if (_liveVideoController.session.running && 
        UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) 
    {
        [_liveVideoController.session stopRunning];
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
        _photoPopoverController = [[UIPopoverController alloc] initWithContentViewController:mediaUI];
        //[popoverController setDelegate:self];
        [_photoPopoverController presentPopoverFromBarButtonItem:self.navigationItem.leftBarButtonItem 
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
    
    // stop the live video session
    if (_liveVideoController.session.running) {
        [_liveVideoController.session stopRunning];
        _algorithmHandler.liveVideoIsRunning = FALSE;
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
        
        NSLog(@"You have a recorded a video.");
        
        //NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        // Do something with the picked movie available at moviePath
    }
}


// For responding to the user tapping Cancel whether in the camera or photo library.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker 
{
    // if the live video was running before taking/uploading a photo (aka "paused"), restart
    if ([_liveVideoController isPaused]) {
        [_liveVideoController.session startRunning];
        _algorithmHandler.liveVideoIsRunning = TRUE;
        _liveVideoController.paused = YES;
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
