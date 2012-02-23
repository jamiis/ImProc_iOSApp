//
//  OFMainPhotoView.m
//  ImgProc
//
//  Created by Jamis Johnson on 2/22/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFMainPhotoView.h"

@implementation OFMainPhotoView

@synthesize originalImageView = _originalImageView;
@synthesize editedImageView = _editedImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSLog(@"initializing OFMainPhotoView");
        
        _originalImageView = [[UIImageView alloc] initWithFrame:frame];
        //_originalImageView.frame = CGRectMake(0.0, 0.0, 280.0, 40.0);
        [self addSubview:_originalImageView];
        [_originalImageView release];
    }
    return self;
}

- (void)setOriginalImageView:(UIImageView*)imageView
{
    NSLog(@"I am now setting the originalImage with frame to x:0, y:0, w: %3.2f, h: %3.2f", self.frame.size.width, self.frame.size.height);
    NSLog(@"imageView.description: %@", imageView.description);
    NSLog(@"%@",imageView.image);
    _originalImageView = imageView;
    _originalImageView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [self addSubview:_originalImageView];
    NSLog(@"subviews.count: %i",self.subviews.count);
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
