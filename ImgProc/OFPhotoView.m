//
//  OFMainPhotoView.m
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFPhotoView.h"
#import "Constants.h"
#import "OFHelperFunctions.h"
#import "ImageConverter.h"

@implementation OFPhotoView

@synthesize delegate = _delegate, 
            isInAlgorithmView = _isInAlgorithmView,
            viewingMode = _viewingMode,
            editedImageView = _editedImageView, 
originalImageView = _originalImageView;

const NSInteger kOriginalImageViewTag = 1;
const NSInteger kEditedImageViewTag = 2;

const float kViewFrameMaxY = 300.0;
const float kViewFrameMaxX = 280.0;




#pragma mark - Lifecycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _isInAlgorithmView = FALSE;
        _viewingMode = PHOTO_MODE;
        
        // create an UIImageView to hold the ORIGINAL image
        _originalImageView = [[UIImageView alloc] init];
        _originalImageView.tag = kOriginalImageViewTag;
        _originalImageView.center = self.center;
        [self addSubview:_originalImageView];
        
        // create an UIImageView to hold the EDITED image
        _editedImageView = [[UIImageView alloc] init];
        _editedImageView.tag = kEditedImageViewTag;
        [self addSubview:_editedImageView];
        //[_editedImageView release];
    }
    return self;
}




#pragma mark - Overrides
- (void)setOriginalImage:(UIImage*)image
{
//    NSLog(@"ORIG image size: %3.6f, %3.6f", image.size.width, image.size.height);
    
    _originalImageView.image = image;
    [self resizeImageView:_originalImageView];
    _editedImageView.image = NULL;

    NSLog(@"ORIG image size: %3.6f, %3.6f", _originalImageView.image.size.width, _originalImageView.image.size.height);
//    NSLog(@"ORIG frame size: %3.6f, %3.6f", _originalImageView.frame.size.width, _originalImageView.frame.size.height);
}


- (void)setEditedImage:(UIImage*)image
{
//    NSLog(@"EDIT image size: %3.6f, %3.6f", image.size.width, image.size.height);
    
    _editedImageView.image = image;
    [self resizeImageView:_editedImageView];

    NSLog(@"EDIT image size: %3.6f, %3.6f", _editedImageView.image.size.width, _editedImageView.image.size.height);
//    NSLog(@"EDIT frame size: %3.6f, %3.6f", _editedImageView.frame.size.width, _editedImageView.frame.size.height);
}




#pragma mark - Animations and Resizing
/* resizes the subview holding a photo to best fit the containing UIView */
- (void)resizeImageView:(UIImageView*)imgView
{
    // compute scale factor for imageView
    float widthScale  = self.frame.size.width / imgView.image.size.width;
    float heightScale = self.frame.size.height / imgView.image.size.height;
    
    CGFloat imageViewXOrigin = 0;
    CGFloat imageViewYOrigin = 0;
    CGFloat imageViewWidth;
    CGFloat imageViewHeight;
    
    // if image is narrow and tall, scale to width and align vertically to the top
    if (widthScale > heightScale) {
        imageViewWidth  = imgView.image.size.width  * heightScale;
        imageViewHeight = imgView.image.size.height * heightScale;
        imageViewXOrigin = (self.frame.size.width - imageViewWidth)/2.0;
    }
    
    // else if image is wide and short, scale to height and align horizontally centered
    else {
        imageViewWidth  = imgView.image.size.width  * widthScale;
        imageViewHeight = imgView.image.size.height * widthScale;
        imageViewYOrigin = (self.frame.size.height - imageViewHeight)/2.0;
    }
    
    imgView.frame = CGRectMake(imageViewXOrigin, imageViewYOrigin, imageViewWidth, imageViewHeight);
}


/* resize entire view, different for ipad and iphone */
- (void)resizeGivenBounds:(CGRect)bounds
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        float margin = 60.0;
        self.frame = CGRectMake(margin, margin, 
                                bounds.size.width  - 2*margin, 
                                bounds.size.height - 2*margin - SCROLLVIEW_HEIGHT);
    }
    else {
        float margin = 15.0;
        //    _photoView.frame = CGRectMake(15.0, 15.0, 290.0, 312.0);
        self.frame = CGRectMake(margin, margin, 
                                bounds.size.width  - 2*margin, 
                                bounds.size.height - 2*margin - SCROLLVIEW_HEIGHT);
    }
}


- (void)animateToAlgorithmViewGivenBounds:(CGRect)bounds
{
    NSLog(@"animationToAlgorithmView");
    /*
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    float new_center_y = appFrame.size.height/2.0 - (appFrame.size.height - self.view.frame.size.height);
    self.center = CGPointMake(self.center.x, new_center_y);
     */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
    }
    else {
    }
}


- (void)animateToMainViewGivenBounds:(CGRect)bounds
{
    NSLog(@"animating to main view yo!");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // do some ipad'ing
    }
    else {
        // do some iphone shis
    }
}




/*
#pragma mark - Touch Events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isInAlgorithmView) {
        UITouch *touch = [touches anyObject];
        
        // gets the coordinats of the touch with respect to the specified view. 
        CGPoint touchPoint = [touch locationInView:self];
        if ([self isInImageView:touchPoint]) {
            //[_delegate animateToMainViewWithTag:0];
            NSLog(@"I have been touched... and I am ashamed :(");
        }
    }
}
*/




#pragma mark - Helper Functions
// checks to see if a point lies within the image being displayed in this UIView (ie. self)
- (BOOL)isInImageView:(CGPoint) point
{
    int width  = _originalImageView.frame.size.width;
    int height = _originalImageView.frame.size.height;
    int x = _originalImageView.frame.origin.x;
    int y = _originalImageView.frame.origin.y;
    
    if (point.x < x || point.x > x + width || point.y < y || point.y > y + height) {
        return FALSE;
    }
    else {
        return TRUE;
    }
}


// simple helper function to print the contents of a frame combined with some prefix
- (void)printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix
{
    NSString* printStr = [prefix stringByAppendingString:@": x: %3.2f, y: %3.2f, w: %3.2f, h: %3.2f"];
    CGPoint origOrig = rect.origin;
    CGSize  origSize = rect.size;
    NSLog(printStr, origOrig.x, origOrig.y, origSize.width, origSize.height);
}


@end
