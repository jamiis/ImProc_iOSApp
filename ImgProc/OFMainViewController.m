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
#import "OFPhotoView.h"
#import "ImProc.h"

@implementation OFMainViewController

@synthesize scrollView = _scrollView, 
            navController = _navController, 
            photoView = _photoView, 
            algorithmControlsView = _algorithmControlsView, 
            currentAlgorithmTag = _currentAlgorithm;

static int imgCount = 0;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    
    // SCROLL VIEW OF BUTTONS
    _scrollView = [[UIScrollView alloc] init];
    // add the scrollview to this viewcontroller's view
    [self.view addSubview:_scrollView];
    [_scrollView release];
    
    
    // NAVIGATION BAR BUTTONS
    // button on NavigationBar to take/upload a photo/video
    UIBarButtonItem *photoSelectionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera 
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
    //[_photoView setDelegate:self];
    [self.view addSubview:_photoView];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup background view of app
    self.view.backgroundColor = [UIColor clearColor];
    
    // SCROLL VIEW
    // configure the scrollview at the bottom of the app
    // the scrollview holds all the img processing algorithm buttons
    [_scrollView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	[_scrollView setCanCancelContentTouches:NO];
	[_scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
	[_scrollView setClipsToBounds:YES];		// default is NO, we want to restrict drawing within our scrollview
	[_scrollView setScrollEnabled:YES];
    [_scrollView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    // load all the images for the algorithm buttons and add them to the scroll view
	NSUInteger i;
	for (i = 1; i <= NUM_ALGORITHMS; i++)
	{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // set button image
        UIImage * buttonImage;
        switch (i) {
            case ALGORITHM_CONTRAST_D:
                buttonImage = [UIImage imageNamed:@"contrast-button.png"];
                break;
            case ALGORITHM_INVERT_D:
                buttonImage = [UIImage imageNamed:@"invert-button.png"];
                break;
            case ALGORITHM_BRIGHTNESS_D:
                buttonImage = [UIImage imageNamed:@"brightness-button.png"];
                break;
            case ALGORITHM_THRESHOLD_D:
                buttonImage = [UIImage imageNamed:@"threshold-button.png"];
                break;
            case ALGORITHM_GAMMA_CORR_D:
                buttonImage = [UIImage imageNamed:@"gamma-button.png"];
                break;
            default:
                buttonImage = [UIImage imageNamed:@"algo-demo-1.png"];
                break;
        }
        
        // buttonYPos makes sure the button is in the vertical center of the scrollView
        float buttonYPos = abs((SCROLLVIEW_HEIGHT - buttonImage.size.height)/2.0);
        [button setFrame:CGRectMake(0.0, buttonYPos, buttonImage.size.width, buttonImage.size.height)];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [button setTag:i];
        [button addTarget:self action:@selector(scrollViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];
	}
    
    // now place the photos in the scrollview, sequentialy and evenly spaced
    [self layoutScrollImages];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // make sure the status bar isn't showing
    [OFHelperFunctions hideStatusBar];
    
    // bounds of the view. note: self.view.bounds is not correct until this point. it changes after viewDidLoad:
    CGRect bounds = self.view.bounds;
    
    // SCROLL VIEW
    float scrollPosY = bounds.size.height - SCROLLVIEW_HEIGHT;
    _scrollView.frame = CGRectMake(0.0, scrollPosY, bounds.size.width, SCROLLVIEW_HEIGHT);
    
    // PHOTO VIEW
    _photoView.frame = PHOTOVIEW_FRAME;
    _photoView.backgroundColor = [UIColor clearColor];
    
    // set the photoView's originalImage to our example image
    if (_photoView.originalImageView.image == nil) {
        NSLog(@"setting orignal photo in viewWillAppear to paris.png");
        [_photoView setOriginalImage:[UIImage imageNamed:@"flatiron.png"]];
    }
    
    // ALGORITHM VIEW -- Initially hidden
    _algorithmControlsView = [[OFAlgorithmControlsView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, 320.0, ALGORITHM_VIEW_HEIGHT)];
    [_algorithmControlsView setDelegate:self];
    [self.view addSubview:_algorithmControlsView];
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}



- (void)dealloc
{	
	[_photoView release];
    [_scrollView release];
	
	[super dealloc];
}



#pragma mark - ScrollView Methods

- (void)layoutScrollImages
{
	UIButton *button = nil;
	NSArray *subviews = [_scrollView subviews];
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (button in subviews)
	{
		if ([button isKindOfClass:[UIButton class]] && button.tag > 0)
		{
			CGRect frame = button.frame;
			frame.origin.x = curXLoc + SCROLLVIEW_SPACE_BETWEEN_BUTTONS;
			button.frame = frame;
			
            // the next button position is one button's width away plus 2 left & right buffers
			curXLoc += (button.frame.size.width + 2.0*SCROLLVIEW_SPACE_BETWEEN_BUTTONS);
		}
	}
	
	// set the content size so it can be scrollable
	[_scrollView setContentSize:CGSizeMake(curXLoc, SCROLLVIEW_HEIGHT)];
}


- (void)scrollViewButtonPressed:(id)sender
{
    UIButton * button = (UIButton *) sender;
    int width  = _photoView.originalImageView.image.size.width;
    int height = _photoView.originalImageView.image.size.height;
    
    NSLog(@"algorithm button pressed with tag: %i", button.tag);
    
    // animate to algorithm view
    [self animateToAlgorithmViewWithTag:button.tag];
    
    UIImage *new_img = nil;
    
    switch (button.tag) {
        case ALGORITHM_CONTRAST_D:
            _photoView.originalImageViewPixelMap = Modify_Contrast_D(_photoView.originalImageViewPixelMap, 2, width, height);
            new_img = [ImageConverter convertBitmapRGBA8ToUIImage:(unsigned char*)_photoView.originalImageViewPixelMap withWidth:width withHeight:height];
            break;
            
        case ALGORITHM_INVERT_D:
            _photoView.originalImageViewPixelMap = Invert_Pixels_D(_photoView.originalImageViewPixelMap, width, height);
            new_img = [ImageConverter convertBitmapRGBA8ToUIImage:(unsigned char*)_photoView.originalImageViewPixelMap withWidth:width withHeight:height];
            break;
            
        case ALGORITHM_BRIGHTNESS_D:
            _photoView.originalImageViewPixelMap = Modify_Brightness_D(_photoView.originalImageViewPixelMap, 35, width, height);
            new_img = [ImageConverter convertBitmapRGBA8ToUIImage:(unsigned char*)_photoView.originalImageViewPixelMap withWidth:width withHeight:height];
            break;
            
        case ALGORITHM_THRESHOLD_D: // threshold
            _photoView.originalImageViewPixelMap = Threshold_D(_photoView.originalImageViewPixelMap, 3, width, height);
            new_img = [ImageConverter convertBitmapRGBA8ToUIImage:(unsigned char*)_photoView.originalImageViewPixelMap withWidth:width withHeight:height];
            break;
            
        case ALGORITHM_GAMMA_CORR_D: // gamma correction
            _photoView.originalImageViewPixelMap = Gamma_Corr_D(_photoView.originalImageViewPixelMap, 3, width, height);
            new_img = [ImageConverter convertBitmapRGBA8ToUIImage:(unsigned char*)_photoView.originalImageViewPixelMap withWidth:width withHeight:height];
            break;
            
        default:
            if (imgCount == 0){
                [_photoView setOriginalImage:[UIImage imageNamed:@"paris.png"]];
                imgCount = 1;
            }
            else {
                [_photoView setOriginalImage:[UIImage imageNamed:@"flatiron.png"]];
                imgCount = 0;
            }    
            NSLog(@"defaulted in scrollViewbuttonPressed switch method");
            break;
    }
    
    if (new_img != nil)
        [_photoView setOriginalImage:new_img];
    else
        NSLog(@"new_img is nil");

    // cleanup
    /*if(bitmap) {
     free(bitmap);	
     bitmap = NULL;
     }*/
}



#pragma mark - Animations
- (void) animateToAlgorithmViewWithTag:(int)tag
{
    // set the photoView to be touchable
    _photoView.isInAlgorithmView = TRUE;
    
    // BEGIN ANIMATION
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // ALGORITHM CONTROLS
    [self.view bringSubviewToFront:_algorithmControlsView];
    float f_y = self.view.frame.size.height - ALGORITHM_VIEW_HEIGHT;
    _algorithmControlsView.frame = CGRectMake(0.0, f_y, 320.0, ALGORITHM_VIEW_HEIGHT);
        
    // SCROLLVIEW
    _scrollView.frame = CGRectMake(_scrollView.frame.origin.x - _scrollView.frame.size.width,
                                   _scrollView.frame.origin.y, 
                                   _scrollView.frame.size.width, 
                                   _scrollView.frame.size.height);
    
    // NAVIGATION BAR
    CGRect navFrame = self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(navFrame.origin.x, 
                                                               navFrame.origin.y - navFrame.size.height,
                                                               navFrame.size.width,
                                                               navFrame.size.height);
    
    // PHOTOVIEW
    // adjust the photoview to be center with the app's main window
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    float new_center_y = appFrame.size.height/2.0 - (appFrame.size.height - self.view.frame.size.height);
    _photoView.center = CGPointMake(_photoView.center.x, new_center_y);
    
    NSLog(@"animating to algorithm view");
    [UIView commitAnimations];
}



- (void) animateToMainViewWithTag:(int)tag
{
    // set photoView to not except touches
    _photoView.isInAlgorithmView = FALSE;
    
    // animate back to main view
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    // ALGORITHM CONTROLS
    _algorithmControlsView.frame = CGRectMake(0.0, self.view.frame.size.height, 320.0, ALGORITHM_VIEW_HEIGHT);
    
    // SCROLLVIEW
    [self.view bringSubviewToFront:_scrollView];
    _scrollView.frame = CGRectMake(_scrollView.frame.origin.x + _scrollView.frame.size.width,
                                   _scrollView.frame.origin.y, 
                                   _scrollView.frame.size.width, 
                                   _scrollView.frame.size.height);
    
    // NAVIGATION BAR
    CGRect navFrame = self.navigationController.navigationBar.frame;
    self.navigationController.navigationBar.frame = CGRectMake(navFrame.origin.x, 
                                                               navFrame.origin.y + navFrame.size.height,
                                                               navFrame.size.width,
                                                               navFrame.size.height);
    
    // PHOTOVIEW
    // adjust the photoview to be center with the app's main window
    _photoView.frame = PHOTOVIEW_FRAME;
    
    NSLog(@"animating to main view");
    [UIView commitAnimations];
}




#pragma mark - OFAlgorithmViewDelegate methods
- (void)algorithmViewBackButtonPressed
{
    NSLog(@"algo view back button pressed, communicating to delegate");
    [self animateToMainViewWithTag:0];
}

- (void)algorithmViewApplyChangesButtonPressed
{
    NSLog(@"algoView apply changes button pressed, this is delegate");
}




#pragma mark - Nav Bar and Action Sheet Methods (UIActionSheetDelegate)

- (void)openPhotoAS:(id)sender
{
	UIActionSheet *photoAS = [[UIActionSheet alloc] initWithTitle:@""
                                                         delegate:self 
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"Take a Photo",@"Photo Library",@"Record a Video",nil,nil];

    // mark A.S. tag so actionSheet:clickedButtonAtIndex:
    // method can identify which functionality to perform
    photoAS.tag = 0;
	
	// use the same style as the nav bar
	photoAS.actionSheetStyle = (UIActionSheetStyle) self.navigationController.navigationBar.barStyle;
	
	[photoAS showInView:self.view];
	[photoAS release];
}

- (void)openActionAS:(id)sender
{
    UIActionSheet *actionAS = [[UIActionSheet alloc] initWithTitle:@""
                                                         delegate:self 
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"Save Photo to Library",@"Share on Facebook",nil,nil];
    
    // mark A.S. tag so actionSheet:clickedButtonAtIndex:
    // method can identify which functionality to perform
    actionAS.tag = 1;
    
    actionAS.actionSheetStyle = (UIActionSheetStyle) self.navigationController.navigationBar.barStyle;
	
    [actionAS showInView:self.view];
    [actionAS release];
}


- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // if opening a photo or video
    if (modalView.tag == 0)
    {
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
                [self startMovieControllerFromViewController:self
                                               usingDelegate:self];
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
                                                   UINavigationControllerDelegate>) delegate {
    
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
    //[UIImagePickerController availableMediaTypesForSourceType:
    //UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}



- (BOOL)startMovieControllerFromViewController: (UIViewController*) controller
                                 usingDelegate: (id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>) delegate {
    
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
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}



- (BOOL)startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    
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
    
    [controller presentModalViewController: mediaUI animated: YES];
    return YES;
}




#pragma mark - UIImagePickerControllerDelegate methods

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToUse;
    
    // Handle a still image taken with camera or picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        editedImage   = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToUse = editedImage;
        } else {
            imageToUse = originalImage;
        }
        
        // dismiss the the modal view BEFORE setting the photo
        // NSLog(@"dismissing view.");
        [self dismissModalViewControllerAnimated: YES];
        [picker release];
        
        // Do something with imageToUse
        [_photoView setOriginalImage:imageToUse];
        
        NSLog(@"photoView.origView.image = %@", _photoView.originalImageView.image.description);
    }
    
    // Handle a movied picked from a photo album
    else if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        NSLog(@"You have a recorded a video.");
        
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        // Do something with the picked movie available at moviePath
    }
}




// For responding to the user tapping Cancel whether in the camera or photo library.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker 
{
    [self dismissModalViewControllerAnimated: YES];
    [picker release];
    
    // hide status bar again
    [OFHelperFunctions hideStatusBar];
}


@end
