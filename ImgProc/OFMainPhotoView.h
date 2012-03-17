//
//  OFMainPhotoView.h
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "Constants.h"
#import "OFHelperFunctions.h"
#import "ImageHelper.h"
#import <UIKit/UIKit.h>

@class OFMainPhotoView;


@protocol OFMainPhotoViewDelegate <NSObject>
@optional
@end



@interface OFMainPhotoView : UIView
{
    id <OFMainPhotoViewDelegate> _delegate;
    BOOL _isInAlgorithmView;
    UIImageView *_originalImageView;
    UIImageView *_editedImageView;
    unsigned char *_originalImageViewBitmap;
}
@property (nonatomic, assign) id <OFMainPhotoViewDelegate> delegate;
@property (nonatomic) BOOL isInAlgorithmView;
@property (nonatomic, retain) UIImageView *originalImageView;
@property (nonatomic, retain) UIImageView *editedImageView;
@property (nonatomic) unsigned char *originalImageViewBitmap;

- (void)setOriginalImage:(UIImage*)image;
- (void)resizeImageView:(UIImageView*)imgView;

//- (UIImageView *)getOriginalImageView;
- (UIImageView *)getEditedImageView;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (BOOL)isInImageView:(CGPoint) point;
- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix;

@end
