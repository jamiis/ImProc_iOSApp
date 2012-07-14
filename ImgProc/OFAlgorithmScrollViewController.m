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
    }
    return self;
}

- (void)dealloc
{
    [_scrollView release];
    _scrollView = nil;
    [super dealloc];
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            switch (buttonIndex) {
                case (ALGORITHM_INVERT):
                    buttonImage = [UIImage imageNamed:@"ipad-button-invert.png"];
                    break;
                case (ALGORITHM_CONTRAST):
                    buttonImage = [UIImage imageNamed:@"ipad-button-contrast.png"];
                    break;
                case ALGORITHM_BRIGHTNESS:
                    buttonImage =  [UIImage imageNamed:@"ipad-button-brightness.png"];
                    break;
                case ALGORITHM_THRESHOLD:
                    buttonImage =  [UIImage imageNamed:@"ipad-button-threshold.png"];
                    break;
                case ALGORITHM_GAMMA:
                    buttonImage =  [UIImage imageNamed:@"ipad-button-gamma.png"];
                    break;
                case ALGORITHM_GRADIENT_MAGNITUDE:
                    buttonImage =  [UIImage imageNamed:@"ipad-button-gradient-magnitude.png"];
                    break;
                case ALGORITHM_FAST_EDGES:
                    buttonImage =  [UIImage imageNamed:@"ipad-button-fast-edges.png"];
                    break;
                case ALGORITHM_GAUSSIAN_BLUR:
                    buttonImage =  [UIImage imageNamed:@"ipad-button-blur.png"];
                    break;
                case ALGORITHM_FAST_SHARPEN:
                    buttonImage =  [UIImage imageNamed:@"ipad-button-sharp.png"];
                    break;
                case ALGORITHM_SOBEL_EDGES:
                    buttonImage = [UIImage imageNamed:@"ipad-button-sobel-edges.png"];
                    break;
                case ALGORITHM_CARTOON:
                    buttonImage = [UIImage imageNamed:@"ipad-button-cartoon.png"];
                    break;
                case ALGORITHM_POSTERIZE:
                    buttonImage = [UIImage imageNamed:@"ipad-button-posterize.png"];
                    break;
                case ALGORITHM_SKETCH:
                    buttonImage = [UIImage imageNamed:@"ipad-button-sketch.png"];
                    break;
                case ALGORITHM_STATIC:
                    buttonImage = [UIImage imageNamed:@"ipad-button-static.png"];
                    break;
                case ALGORITHM_ERODE:
                    buttonImage = [UIImage imageNamed:@"ipad-button-erode.png"];
                    break;
                case ALGORITHM_DILATE:
                    buttonImage = [UIImage imageNamed:@"ipad-button-dilate.png"];
                    break;
                case ALGORITHM_NOISE_REDUCTION:
                    buttonImage = [UIImage imageNamed:@"ipad-button-noise-reduction.png"];
                    break;
                default:
                    buttonImage = [UIImage imageNamed:@"ipad-button-change-photo-2.png"];
                    break;
            }
        } 
        else {
            switch (buttonIndex) {
                case ALGORITHM_INVERT:
                    buttonImage =  [UIImage imageNamed:@"invert-button.png"];
                    break;
                case ALGORITHM_CONTRAST:
                    buttonImage = [UIImage imageNamed:@"contrast-button.png"];
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
                case ALGORITHM_SOBEL_EDGES:
                    buttonImage = [UIImage imageNamed:@"sobel-button.png"];
                    break;
                case ALGORITHM_CARTOON:
                    buttonImage = [UIImage imageNamed:@"cartoon-button.png"];
                    break;
                case ALGORITHM_POSTERIZE:
                    buttonImage = [UIImage imageNamed:@"posterize-button.png"];
                    break;
                case ALGORITHM_SKETCH:
                    buttonImage = [UIImage imageNamed:@"sketch-button.png"];
                    break;
                case ALGORITHM_STATIC:
                    buttonImage = [UIImage imageNamed:@"static-button.png"];
                    break;
                 case ALGORITHM_ERODE:
                    buttonImage = [UIImage imageNamed:@"erode-button.png"];
                    break;
                 case ALGORITHM_DILATE:
                    buttonImage = [UIImage imageNamed:@"dilate-button.png"];
                    break;
                 case ALGORITHM_NOISE_REDUCTION:
                    buttonImage = [UIImage imageNamed:@"noise-reduction-button.png"];
                    break;
                default:
                    buttonImage =  [UIImage imageNamed:@"button-demo-photos.png"];
                    break;
            }
        }
        
        // buttonYPos makes sure the button is in the vertical center of the scrollView
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            float buttonYPos = abs((SCROLLVIEW_HEIGHT_IPAD - buttonImage.size.height)/2.0);
            [button setFrame:CGRectMake(0.0, buttonYPos, buttonImage.size.width, buttonImage.size.height)];
        } else {
            float buttonYPos = abs((SCROLLVIEW_HEIGHT - buttonImage.size.height)/2.0);
            [button setFrame:CGRectMake(0.0, buttonYPos, buttonImage.size.width, buttonImage.size.height)];
        }
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




#pragma mark - Custom Methods
- (void)layoutScrollImages
{
	UIButton *button = nil;
	NSArray *subviews = [_scrollView subviews];
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
    
    // place buttons differently based on ipad vs. iphone/ipod
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        for (button in subviews)
        {
            if ([button isKindOfClass:[UIButton class]] && button.tag > 0)
            {
                CGRect frame = button.frame;
                frame.origin.x = curXLoc + SCROLLVIEW_SPACE_BETWEEN_BUTTONS_IPAD;
                button.frame = frame;
                
                // the next button position is one button's width away plus 2 left & right buffers
                curXLoc += (button.frame.size.width + 2.0*SCROLLVIEW_SPACE_BETWEEN_BUTTONS_IPAD);
            }
        }
        // set the content size so it can be scrollable
        [_scrollView setContentSize:CGSizeMake(curXLoc, SCROLLVIEW_HEIGHT_IPAD)];
    } 
    else {
        for (button in subviews)
        {
            if ([button isKindOfClass:[UIButton class]] && button.tag > 0)
            {
                CGRect frame = button.frame;
                frame.origin.x = curXLoc + SCROLLVIEW_SPACE_BETWEEN_BUTTONS;
                button.frame = frame;
                curXLoc += (button.frame.size.width + 2.0*SCROLLVIEW_SPACE_BETWEEN_BUTTONS);
            }
        }
        [_scrollView setContentSize:CGSizeMake(curXLoc, SCROLLVIEW_HEIGHT)];
    }
}


- (void)scrollViewButtonPressed:(id)sender 
{ 
    [_delegate scrollViewButtonPressed:sender]; 
}


- (void)resizeInFrame:(CGRect)frame
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        float scrollPosY = frame.size.height - SCROLLVIEW_HEIGHT_IPAD;
        self.view.frame = CGRectMake(0.0, scrollPosY, frame.size.width, SCROLLVIEW_HEIGHT_IPAD);
        _scrollView.frame = CGRectMake(0.0, 0.0, frame.size.width, SCROLLVIEW_HEIGHT_IPAD);

    }
    else {
        float scrollPosY = frame.size.height - SCROLLVIEW_HEIGHT;
        self.view.frame = CGRectMake(0.0, scrollPosY, frame.size.width, SCROLLVIEW_HEIGHT);
        _scrollView.frame = CGRectMake(0.0, 0.0, frame.size.width, SCROLLVIEW_HEIGHT);

    }
}

@end
