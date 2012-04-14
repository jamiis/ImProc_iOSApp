//
//  HelperFunctions.m
//  ImgProc
//
//  Created by Jamis Johnson on 2/24/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFHelperFunctions.h"

@implementation OFHelperFunctions

+ (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix
{
    NSString* printStr = [prefix stringByAppendingFormat:@" ==> x: %3.2f, y: %3.2f, w: %3.2f, h: %3.2f"];
    CGSize origSize = rect.size;
    CGPoint origOrig = rect.origin;
    NSLog(printStr, origOrig.x, origOrig.y, origSize.width, origSize.height);
}

+ (void) hideStatusBar
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    //[UIApplication sharedApplication].keyWindow.frame=CGRectMake(0, 0, 320, 480);
}

@end
