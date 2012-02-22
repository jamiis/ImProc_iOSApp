//
//  AlgorithmSelectorScrollViewController.h
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OFMainViewController : UIViewController <UINavigationBarDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIScrollView *_scrollView;
    UINavigationController *_navController;
}

@property (nonatomic, retain) UIScrollView *_scrollView;
@property (nonatomic, retain) UINavigationController *_navController;

- (void)layoutScrollImages;
- (void)scrollViewButtonPressed;
- (BOOL)startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate;
- (BOOL)startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate;

@end
