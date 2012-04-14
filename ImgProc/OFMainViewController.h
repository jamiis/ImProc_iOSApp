//
//  AlgorithmSelectorScrollViewController.h
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "Constants.h"
#import "OFAlgorithmControlsView.h"
#import "OFLiveVideo.h"
#import "OFPhotoView.h"
#import "OFAlgorithmHandler.h"
#import "OFAlgorithmScrollViewController.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/UTCoreTypes.h>

@class OFPhotoView;

@interface OFMainViewController : UIViewController <UINavigationBarDelegate, 
                                                    UIActionSheetDelegate, 
                                                    UIImagePickerControllerDelegate,
                                                    UINavigationControllerDelegate, 
                                                    OFAlgorithmControlsViewDelegate,
                                                    OFLiveVideoDelegate,
                                                    OFAlgorithmHandlerDelegate,
                                                    OFAlgorithmScrollViewControllerDelegate> 
{
    OFAlgorithmScrollViewController *_scrollViewController;
    OFPhotoView *_photoView;
    OFLiveVideo *_liveVideoController;
    OFAlgorithmControlsView *_algorithmControlsView;
    OFAlgorithmHandler *_algorithmHandler;
}

@property (nonatomic, retain) OFAlgorithmScrollViewController *scrollViewController;
@property (nonatomic, retain) OFPhotoView *photoView;
@property (nonatomic, retain) OFLiveVideo *liveVideoController;
@property (nonatomic, retain) OFAlgorithmControlsView *algorithmControlsView;
@property (nonatomic, retain) OFAlgorithmHandler *algorithmHandler;

//@property (nonatomic, retain) UIActionSheet *photoAS;
//@property (nonatomic, retain) UIActionSheet *actionAS;


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
- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix;

@end
