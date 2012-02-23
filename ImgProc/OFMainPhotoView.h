//
//  OFMainPhotoView.h
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OFMainPhotoView : UIView
{
    UIImageView *_originalImageView;
    UIImageView *_editedImageView;
}

@property (nonatomic, retain) UIImageView *originalImageView;
@property (nonatomic, retain) UIImageView *editedImageView;

@end
