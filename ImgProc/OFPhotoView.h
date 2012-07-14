//
//  OFMainPhotoView.h
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImProc_Base.h"

@class OFPhotoView;

@protocol OFPhotoViewDelegate <NSObject>
@optional
@end


@interface OFPhotoView : UIView
{
    id <OFPhotoViewDelegate> _delegate;
    BOOL _isInAlgorithmView;
    UIImageView *_originalImageView;
    UIImageView *_editedImageView;
}
@property (nonatomic, assign) id <OFPhotoViewDelegate> delegate;
@property (nonatomic) BOOL isInAlgorithmView;
@property (nonatomic, retain) UIImageView *originalImageView;
@property (nonatomic, retain) UIImageView *editedImageView;

- (void)setOriginalImage:(UIImage*)image;
- (void)setEditedImage:(UIImage*)image;
- (void)resizeImageView:(UIImageView*)imgView;
- (UIImage*)resizeOriginalImage:(UIImage*)image;
- (BOOL)isInImageView:(CGPoint) point;
- (void)resizeGivenBounds:(CGRect)bounds;
- (void)animateToAlgorithmViewGivenBounds:(CGRect)bounds;
- (void)animateToMainViewGivenBounds:(CGRect)bounds;
- (void)printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix;

@end
