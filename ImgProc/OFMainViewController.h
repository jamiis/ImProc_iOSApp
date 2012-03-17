//
//  AlgorithmSelectorScrollViewController.h
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFMainPhotoView.h"
#import "Constants.h"
#import "OFHelperFunctions.h"
#import "OFImageProcHelperFunctions.h"
#import "ImageHelper.h"
#import "ImProc.h"
#import "OFAlgorithmView.h"

#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@interface OFMainViewController : UIViewController <UINavigationBarDelegate, 
                                                    UIActionSheetDelegate, 
                                                    UIImagePickerControllerDelegate,
                                                    UINavigationControllerDelegate,OFAlgorithmViewDelegate>
{
    UIScrollView *_scrollView;
    UINavigationController *_navController;
    OFMainPhotoView *_photoView;
    OFAlgorithmView *_algorithmControlsView;
}

@property (nonatomic, retain) UIScrollView *_scrollView;
@property (nonatomic, retain) UINavigationController *_navController;
@property (nonatomic, retain) OFMainPhotoView *_photoView;
@property (nonatomic, retain) OFAlgorithmView *_algorithmControlsView;

- (void)layoutScrollImages;
- (void)scrollViewButtonPressed:(id)sender;
- (void)animateToAlgorithmViewWithTag:(int)tag;
- (void)animateToMainViewWithTag:(int)tag;
- (void)algorithmViewBackButtonPressed;

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
