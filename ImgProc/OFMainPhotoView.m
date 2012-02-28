//
//  OFMainPhotoView.m
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFMainPhotoView.h"

@implementation OFMainPhotoView

const NSInteger kOriginalImageViewTag = 1;
const NSInteger kEditedImageViewTag = 2;

const float kViewFrameMaxY = 300.0;
const float kViewFrameMaxX = 280.0;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // create an UIImageView to hold the ORIGINAL image
        UIImageView *originalImageView = [[UIImageView alloc] init];
        originalImageView.tag = kOriginalImageViewTag;
        originalImageView.contentMode = UIViewContentModeScaleAspectFit;
        originalImageView.center = self.center;
        
        [self addSubview:originalImageView];
        [originalImageView release];
        
        // create an UIImageView to hold the EDITED image
        UIImageView *editedImageView = [[UIImageView alloc] init];
        editedImageView.tag = kEditedImageViewTag;
        [self addSubview:editedImageView];
        [editedImageView release];
    }
    return self;
}



- (void)setOriginalImage:(UIImage*)image
{
    // figure out self.view.frame size according to photo size
    UIImageView *origView = [self getOriginalImageView];
    NSLog(@"old image description: %@",origView.image.description);
    origView.image = image;
    [self resizeImageView:origView];
    NSLog(@"new image description: %@",origView.image.description);
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
 



#pragma mark - Helper Functions
- (UIImageView*)getOriginalImageView { return (UIImageView *)[self viewWithTag:kOriginalImageViewTag]; }
- (UIImageView*)getEditedImageView { return (UIImageView *)[self viewWithTag:kEditedImageViewTag]; }

- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix
{
    NSString* printStr = [prefix stringByAppendingString:@" ==> x: %3.2f, y: %3.2f, w: %3.2f, h: %3.2f"];
    CGPoint origOrig = rect.origin;
    CGSize  origSize = rect.size;
    NSLog(printStr, origOrig.x, origOrig.y, origSize.width, origSize.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
