//
//  OFMainPhotoView.h
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImProc.h"

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
//    unsigned char *_originalImageViewBitmap;
    pixel* _originalImageViewPixelMap;
}
@property (nonatomic, assign) id <OFPhotoViewDelegate> delegate;
@property (nonatomic) BOOL isInAlgorithmView;
@property (nonatomic, retain) UIImageView *originalImageView;
@property (nonatomic, retain) UIImageView *editedImageView;
//@property (nonatomic) unsigned char *originalImageViewBitmap;
@property (nonatomic) pixel *originalImageViewPixelMap;

- (void)setOriginalImage:(UIImage*)image;
- (void)resizeImageView:(UIImageView*)imgView;

//- (UIImageView *)getOriginalImageView;
- (UIImageView *)getEditedImageView;

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

- (BOOL)isInImageView:(CGPoint) point;
- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix;

@end
