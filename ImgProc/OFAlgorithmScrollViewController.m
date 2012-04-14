//
//  OFAlgorithmScrollViewController.m
//  ImgProc
//
//  Created by Jamis Johnson on 4/6/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFAlgorithmScrollViewController.h"
#import "Constants.h"

@interface OFAlgorithmScrollViewController ()
- (void)layoutScrollImages;
@end


@implementation OFAlgorithmScrollViewController

@synthesize delegate   = _delegate,
            scrollView = _scrollView;

- (id)init
{
    self = [super init];
    if (self) {
        // initialize the scrollview
        _scrollView = [[UIScrollView alloc] init];
        [self.view addSubview:_scrollView];
        //[self.view bringSubviewToFront:_scrollView];
        //[_scrollView release];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor underPageBackgroundColor]];
    
    [_scrollView setBackgroundColor:[UIColor clearColor]];
	[_scrollView setCanCancelContentTouches:NO];
	[_scrollView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
	[_scrollView setClipsToBounds:YES];		// default is NO, we want to restrict drawing within our scrollview
	[_scrollView setScrollEnabled:YES];
    [_scrollView setContentInset:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    // load all the images for the algorithm buttons and add them to the scroll view
	for (NSUInteger buttonIndex = 1; buttonIndex <= NUM_ALGORITHMS; buttonIndex++)
	{
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        // set button image based on button index
        UIImage *buttonImage;
        switch (buttonIndex) {
            case ALGORITHM_CONTRAST:
                buttonImage = [UIImage imageNamed:@"contrast-button.png"];
                break;
            case ALGORITHM_INVERT:
                buttonImage =  [UIImage imageNamed:@"invert-button.png"];
                break;
            case ALGORITHM_BRIGHTNESS:
                buttonImage =  [UIImage imageNamed:@"brightness-button.png"];
                break;
            case ALGORITHM_THRESHOLD:
                buttonImage =  [UIImage imageNamed:@"threshold-button.png"];
                break;
            case ALGORITHM_GAMMA:
                buttonImage =  [UIImage imageNamed:@"gamma-button.png"];
                break;
            case ALGORITHM_GRADIENT_MAGNITUDE:
                buttonImage =  [UIImage imageNamed:@"gradient-magnitude-button.png"];
                break;
            case ALGORITHM_FAST_EDGES:
                buttonImage =  [UIImage imageNamed:@"edges-button.png"];
                break;
            case ALGORITHM_GAUSSIAN_BLUR:
                buttonImage =  [UIImage imageNamed:@"blur-button.png"];
                break;
            case ALGORITHM_FAST_SHARPEN:
                buttonImage =  [UIImage imageNamed:@"sharpen-button.png"];
                break;
            default:
                buttonImage =  [UIImage imageNamed:@"button-demo.png"];
                break;
        }
        
        // buttonYPos makes sure the button is in the vertical center of the scrollView
        float buttonYPos = abs((SCROLLVIEW_HEIGHT - buttonImage.size.height)/2.0);
        [button setFrame:CGRectMake(0.0, buttonYPos, buttonImage.size.width, buttonImage.size.height)];
        [button setImage:buttonImage forState:UIControlStateNormal];
        [button setTag:buttonIndex];
        [button addTarget:self action:@selector(scrollViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:button];
	}
    
    // now place the photos in the scrollview, sequentialy and evenly spaced
    [self layoutScrollImages];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


/*
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/




#pragma mark - Custom Methods
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



- (void)scrollViewButtonPressed:(id)sender { [_delegate scrollViewButtonPressed:sender]; }



#pragma mark - Animation Methods
- (void)animateViewOnScreen
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x - self.view.frame.size.width,
                                     self.view.frame.origin.y, 
                                     self.view.frame.size.width, 
                                     self.view.frame.size.height);
    }
    else
    {
        UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
        if (orientation == UIInterfaceOrientationPortrait)
        {
            self.view.frame = CGRectMake(self.view.frame.origin.x - self.view.frame.size.width,
                                         self.view.frame.origin.y, 
                                         self.view.frame.size.width, 
                                         self.view.frame.size.height);
        }
    }
}


- (void)animateViewOffScreen
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.view.frame = CGRectMake(self.view.frame.origin.x + self.view.frame.size.width,
                                     self.view.frame.origin.y, 
                                     self.view.frame.size.width, 
                                     self.view.frame.size.height);
    }
    else
    {
        UIInterfaceOrientation orientation = [[UIDevice currentDevice] orientation];
        if (orientation == UIInterfaceOrientationPortrait)
        {
            self.view.frame = CGRectMake(self.view.frame.origin.x + self.view.frame.size.width,
                                         self.view.frame.origin.y, 
                                         self.view.frame.size.width, 
                                         self.view.frame.size.height);
        }
    }
}


- (void)rearrangeButtons:(CGRect)bounds
{
    NSLog(@"rearranging buttons!");
    //float scrollPosY = bounds.size.height - SCROLLVIEW_HEIGHT;
    //self.view.frame   = CGRectMake(0.0, scrollPosY, bounds.size.width, SCROLLVIEW_HEIGHT);
    //_scrollView.frame = CGRectMake(0.0, 0.0, bounds.size.width, SCROLLVIEW_HEIGHT);
    
    // TODO: ADJUST TO WORK WITH IPAD AND ROTATED IPHONE
}


- (void)resizeInFrame:(CGRect)frame
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        float scrollPosY = frame.size.height - SCROLLVIEW_HEIGHT;
        self.view.frame = CGRectMake(0.0, scrollPosY, frame.size.width, SCROLLVIEW_HEIGHT);
        _scrollView.frame = CGRectMake(0.0, 0.0, frame.size.width, SCROLLVIEW_HEIGHT);

    }
    else {
        float scrollPosY = frame.size.height - SCROLLVIEW_HEIGHT;
        self.view.frame = CGRectMake(0.0, scrollPosY, frame.size.width, SCROLLVIEW_HEIGHT);
        _scrollView.frame = CGRectMake(0.0, 0.0, frame.size.width, SCROLLVIEW_HEIGHT);

    }
}

@end
