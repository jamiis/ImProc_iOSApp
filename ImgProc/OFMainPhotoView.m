//
//  OFMainPhotoView.m
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFMainPhotoView.h"

@implementation OFMainPhotoView

@synthesize delegate = _delegate, 
            isInAlgorithmView = _isInAlgorithmView, 
            editedImageView = _editedImageView, 
            originalImageView = _originalImageView, 
            originalImageViewBitmap = _originalImageViewBitmap;

const NSInteger kOriginalImageViewTag = 1;
const NSInteger kEditedImageViewTag = 2;

const float kViewFrameMaxY = 300.0;
const float kViewFrameMaxX = 280.0;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        _isInAlgorithmView = FALSE;
        
        // create an UIImageView to hold the ORIGINAL image
        _originalImageView = [[UIImageView alloc] init];
        _originalImageView.tag = kOriginalImageViewTag;
        _originalImageView.contentMode = UIViewContentModeScaleAspectFit;
        _originalImageView.center = self.center;
        [self addSubview:_originalImageView];
        
        // create an UIImageView to hold the EDITED image
        _editedImageView = [[UIImageView alloc] init];
        _editedImageView.tag = kEditedImageViewTag;
        [self addSubview:_editedImageView];
        [_editedImageView release];
    }
    return self;
}



- (void)setOriginalImage:(UIImage*)image
{
    _originalImageView.image = image;
    [self resizeImageView:_originalImageView];
    
    // set originalImageViewBitmap
    _originalImageViewBitmap = [ImageHelper convertUIImageToBitmapRGBA8:_originalImageView.image];
}




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
 


#pragma mark - Touch Events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isInAlgorithmView) {
        UITouch *touch = [touches anyObject];
        
        // gets the coordinats of the touch with respect to the specified view. 
        CGPoint touchPoint = [touch locationInView:self];
        if ([self isInImageView:touchPoint]) {
            [_delegate animateToMainViewWithTag:0];
            NSLog(@"I have been touched... and I am ashamed :(");
        }
    }
}




#pragma mark - Helper Functions

/*
// returns the original image, not the one being edited.
- (UIImageView *)getOriginalImageView { 
    return (UIImageView *)[self viewWithTag:kOriginalImageViewTag]; 
}
*/


// returns the image that is being edited
- (UIImageView *)getEditedImageView 
{ 
    return (UIImageView *)[self viewWithTag:kEditedImageViewTag]; 
}


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
- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix
{
    NSString* printStr = [prefix stringByAppendingString:@" ==> x: %3.2f, y: %3.2f, w: %3.2f, h: %3.2f"];
    CGPoint origOrig = rect.origin;
    CGSize  origSize = rect.size;
    NSLog(printStr, origOrig.x, origOrig.y, origSize.width, origSize.height);
}


@end
