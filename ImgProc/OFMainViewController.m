//
//  AlgorithmSelectorScrollViewController.m
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFMainViewController.h"

@implementation OFMainViewController

@synthesize _scrollView, _navController, _photoView;

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
    _photoView = [[OFMainPhotoView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.view addSubview:_photoView];
    //[_photoView release];
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // setup background view of app
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
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
    
    // load all the images for the algorithm button and add them to the scroll view
	NSUInteger i;
	for (i = 1; i <= NUM_ALGORITHMS; i++)
	{
        // create custom button with image
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * buttonImage = [UIImage imageNamed:@"algo-demo-1.png"];
        // buttonYPos makes sure the button is in the vertical center of the scrollView
        float buttonYPos = abs((SCROLLVIEW_HEIGHT - buttonImage.size.height)/2.0);
        [button setFrame:CGRectMake(0.0, buttonYPos, buttonImage.size.width, buttonImage.size.height)];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [button setTag:i];
        [button addTarget:self action:@selector(scrollViewButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];
	}
    
    // now place the photos in the scrollview, sequentialy and evenly spaced
    [self layoutScrollImages];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // make sure the status bar isn't showing
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [UIApplication sharedApplication].keyWindow.frame=CGRectMake(0, 0, 320, 480); 
    
    // bounds of the view. note: self.view.bounds is not correct until this point. it changes after viewDidLoad:
    CGRect bounds = self.view.bounds;
    
    // SCROLL VIEW
    float scrollPosY = bounds.size.height - SCROLLVIEW_HEIGHT;
    _scrollView.frame = CGRectMake(0.0, scrollPosY, bounds.size.width, SCROLLVIEW_HEIGHT);
    
    // PHOTO VIEW
    // position the photoView, the view that holds the photo being processed
    _photoView.frame = PHOTOVIEW_FRAME;
    
    // set the background color of the photoView
    _photoView.backgroundColor = [UIColor clearColor];
    
    // PHOTO VIEW
    // set the photoView's originalImage to our example image
    if ([[_photoView getOriginalImageView] image] == nil) {
        NSLog(@"setting orignal photo in viewWillAppear to paris.png");
        [_photoView setOriginalImage:[UIImage imageNamed:@"paris.png"]];
    }
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


- (void)scrollViewButtonPressed
{
    NSLog(@"ALGORITHM BUTTON PRESSED YAY");
    
    if (imgCount==0){
        [_photoView setOriginalImage:[UIImage imageNamed:@"flatiron.png"]];
        imgCount = 1;
    }
    else {
        [_photoView setOriginalImage:[UIImage imageNamed:@"paris.png"]];
        imgCount = 0;
    }
}



#pragma mark - NavigationBar Buttons Methods

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



#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)modalView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // if opening a photo or video
    if (modalView.tag == 0)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                NSLog(@"Case 0 pressed");
                [self startCameraControllerFromViewController:self 
                                                usingDelegate:self];
                // hide the status bar. might not be necessary but just to be safe:
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
                break;
            }
            case 1:
            {
                NSLog(@"Case 1 pressed");
                [self startMediaBrowserFromViewController:self
                                            usingDelegate:self];
                // hide the status bar. might not be necessary but just to be safe:
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
                break;
            }
            case 2:
            {
                NSLog(@"Case 2 pressed");
                [self startMovieControllerFromViewController:self
                                               usingDelegate:self];
                // hide the status bar. might not be necessary but just to be safe:
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
                break;
            }
        }
    }
    
    // if top-right action button on the uinavigationbar was selected
    if (modalView.tag == 1)
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
        NSLog(@"dismissing view.");
        [self dismissModalViewControllerAnimated: YES];
        [picker release];
        
        // Do something with imageToUse
        [_photoView setOriginalImage:imageToUse];
        
        NSLog(@"photoView.origView.image = %@", [[[_photoView getOriginalImageView] image] description]);
        NSLog(@"\n");
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
    //[picker release];
    
    // hide status bar again
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [UIApplication sharedApplication].keyWindow.frame=CGRectMake(0, 0, 320, 480); 
}


@end
