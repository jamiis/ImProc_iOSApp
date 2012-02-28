//
//  OFMainPhotoView.h
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "Constants.h"
#import "OFHelperFunctions.h"
#import <UIKit/UIKit.h>

@interface OFMainPhotoView : UIView
{
    
}

- (void)setOriginalImage:(UIImage*)image;
- (void)resizeImageView:(UIImageView*)imgView;

- (UIImageView*)getOriginalImageView;
- (UIImageView*)getEditedImageView;
- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix;

@end
