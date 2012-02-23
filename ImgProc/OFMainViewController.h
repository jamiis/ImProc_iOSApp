//
//  AlgorithmSelectorScrollViewController.h
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFMainPhotoView.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface OFMainViewController : UIViewController <UINavigationBarDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIScrollView *_scrollView;
    UINavigationController *_navController;
    OFMainPhotoView *_photoView;
}

@property (nonatomic, retain) UIScrollView *_scrollView;
@property (nonatomic, retain) UINavigationController *_navController;
@property (nonatomic, retain) OFMainPhotoView *_photoView;

- (void)layoutScrollImages;
- (void)scrollViewButtonPressed;
- (BOOL)startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate;
- (BOOL)startMediaBrowserFromViewController: (UIViewController*) controller
                              usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate;
- (BOOL)startMovieControllerFromViewController: (UIViewController*) controller
                                 usingDelegate: (id <UIImagePickerControllerDelegate,
                                                  UINavigationControllerDelegate>) delegate;

@end
