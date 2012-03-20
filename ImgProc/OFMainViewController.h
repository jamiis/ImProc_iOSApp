//
//  AlgorithmSelectorScrollViewController.h
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "Constants.h"
#import "OFAlgorithmControlsView.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>
@class OFPhotoView;

@interface OFMainViewController : UIViewController <UINavigationBarDelegate, 
                                                    UIActionSheetDelegate, 
                                                    UIImagePickerControllerDelegate,
                                                    UINavigationControllerDelegate, 
                                                    OFAlgorithmControlsViewDelegate>
{
    UIScrollView *_scrollView;
    UINavigationController *_navController;
    OFPhotoView *_photoView;
    OFAlgorithmControlsView *_algorithmControlsView;
    int _currentAlgorithm;
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UINavigationController *navController;
@property (nonatomic, retain) OFPhotoView *photoView;
@property (nonatomic, retain) OFAlgorithmControlsView *algorithmControlsView;
@property (nonatomic) int currentAlgorithmTag;

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
