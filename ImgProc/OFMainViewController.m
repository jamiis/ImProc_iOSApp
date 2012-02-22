//
//  AlgorithmSelectorScrollViewController.m
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFMainViewController.h"

@implementation OFMainViewController

@synthesize _scrollView, _navController;


const CGFloat kScrollViewHeight = 110.0;
const NSUInteger kNumImages	= 5;
const NSUInteger kSpaceBetweenButtons = 16;



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *photoSelectionButton = [[UIBarButtonItem alloc] initWithTitle:@"Open"
                                                                             style:UIBarButtonItemStylePlain 
                                                                            target:self
                                                                            action:@selector(openPhotoAS:)];
    self.navigationItem.leftBarButtonItem = photoSelectionButton;
    [photoSelectionButton release];
    
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction 
                                                                            target:self 
                                                                            action:@selector(openActionAS:)];
    
    self.navigationItem.rightBarButtonItem = settingsButton;
    [settingsButton release];
    
    // setup general view
    self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
    
    // setup the scrollview add it to the view controller
    _scrollView = [[UIScrollView alloc] init];
    [_scrollView setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	[_scrollView setCanCancelContentTouches:NO];
	[_scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
	[_scrollView setClipsToBounds:YES];		// default is NO, we want to restrict drawing within our scrollview
	[_scrollView setScrollEnabled:YES];
    [_scrollView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    // load all the images from our bundle and add them to the scroll view
	NSUInteger i;
	for (i = 1; i <= kNumImages; i++)
	{
        // create custom button with image
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * buttonImage = [UIImage imageNamed:@"algo-demo-1.png"];
        // buttonYPos makes sure the button is in the vertical center of the scrollView
        float buttonYPos = abs((kScrollViewHeight - buttonImage.size.height)/2.0);
        [button setFrame:CGRectMake(0.0, buttonYPos, buttonImage.size.width, buttonImage.size.height)];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [button setTag:i];
        [button addTarget:self action:@selector(scrollViewButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];
	}
    
    [self layoutScrollImages];	// now place the photos in serial layout within the scrollview
    
    [self.view addSubview:_scrollView];
    [_scrollView release];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // set the scrollView's position. 
    // this is done here instead of viewDidLoad because self.view.bounds isn't correct until this pt.
    float scrollPosY = self.view.bounds.size.height - kScrollViewHeight;
    _scrollView.frame = CGRectMake(0.0, scrollPosY, self.view.bounds.size.width, kScrollViewHeight);
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
			frame.origin.x = curXLoc + kSpaceBetweenButtons;
			button.frame = frame;
			
            // the next button position is one button's width away plus 2 left & right buffers
			curXLoc += (button.frame.size.width + 2.0*kSpaceBetweenButtons);
		}
	}
	
	// set the content size so it can be scrollable
	[_scrollView setContentSize:CGSizeMake(curXLoc, kScrollViewHeight)];
}


- (void)scrollViewButtonPressed
{
    NSLog(@"ALGORITHM BUTTON PRESSED YAY");
}



#pragma mark - NavigationBar Buttons Methods
- (void)openPhotoAS:(id)sender
{
	UIActionSheet *photoAS = [[UIActionSheet alloc] initWithTitle:@""
                                                         delegate:self 
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"Camera",@"Photo Library",nil,nil];

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
                                                otherButtonTitles:@"Save Photo to Library",@"Kiss Paula",nil,nil];
    
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
    // if selecting a photo or video
    if (modalView.tag == 0)
    {
        switch (buttonIndex)
        {
            case 0:
            {
                NSLog(@"Case 0 pressed");
                [self startCameraControllerFromViewController:self 
                                                usingDelegate:self];
                break;
            }
            case 1:
            {
                NSLog(@"Case 1 pressed");
                [self startMediaBrowserFromViewController:self
                                            usingDelegate:self];
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
                NSLog(@"top-right action sheet was selected, button case 0");
                break;
            }
            case 1:
            {
                NSLog(@"You can kiss Paula now!");
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
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"YOU HAVE PICKED AN IMAGE YO!");
}


// For responding to the user tapping Cancel whether in the camera or photo library.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker 
{
    [self dismissModalViewControllerAnimated: YES];
    [picker release];
    // hide status bar again
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [UIApplication sharedApplication].keyWindow.frame=CGRectMake(0, 0, 320, 480); 
}


@end
