//
//  OFAppDelegate.h
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OFMainViewController.h"

@interface OFAppDelegate : UIResponder <UIApplicationDelegate>
{
    OFMainViewController *_algorithmScrollView;
    UINavigationController *_navController;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) OFMainViewController *_algorithmScrollView;
@property (nonatomic, retain) UINavigationController *_navController;


@end
