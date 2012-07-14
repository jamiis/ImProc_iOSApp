//
//  OFAlgorithmScrollViewController.h
//  ImgProc
//
//  Created by Jamis Johnson on 4/6/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol OFAlgorithmScrollViewControllerDelegate <NSObject>
@required
- (void)scrollViewButtonPressed:(id)sender;
@end

@interface OFAlgorithmScrollViewController : UIViewController 
{
    id<OFAlgorithmScrollViewControllerDelegate> _delegate;
    UIScrollView *_scrollView;
}

@property (nonatomic, retain) id<OFAlgorithmScrollViewControllerDelegate> delegate;
@property (nonatomic, retain) UIScrollView *scrollView;

- (void)scrollViewButtonPressed:(id)sender;
- (void)resizeInFrame:(CGRect)frame;

@end
