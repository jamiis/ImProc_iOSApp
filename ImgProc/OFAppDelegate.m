//
//  OFAppDelegate.m
//  ImgProc
//
//  Created by Jamis Johnson on 1/31/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFAppDelegate.h"

@implementation OFAppDelegate

@synthesize window = _window;

@synthesize _algorithmScrollView, _navController;

- (void)dealloc
{
    [_algorithmScrollView release];
    
    [_window release];
    [super dealloc];
}


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [UIColor whiteColor];
    
    // hide status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    [UIApplication sharedApplication].keyWindow.frame=CGRectMake(0, 0, 320, 480);
    
    _algorithmScrollView = [[OFMainViewController alloc] init];
    
    _navController = [[UINavigationController alloc] initWithRootViewController:_algorithmScrollView];
    [_navController.navigationBar setTintColor:[UIColor blackColor]];

    [self.window addSubview:_navController.view];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
