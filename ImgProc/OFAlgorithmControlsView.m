//
//  OFAlgorithmView.m
//  ImgProc
//
//  Created by Jamis Johnson on 3/10/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFAlgorithmControlsView.h"
#import "OFHelperFunctions.h"
#import "Constants.h"

@implementation OFAlgorithmControlsView

@synthesize backButton = _backButton, 
            delegate = _delegate, 
            applyChangesButton = _applyChangesButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor underPageBackgroundColor];
        
        float b_height = 30.0;
        float b_width  = 60.0;
        
        // BACK BUTTON
        _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
        _backButton.frame = CGRectMake(10.0, (self.frame.size.height-b_height)/2.0, b_width, b_height);
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        // APPLY CHANGES BUTTON
        _applyChangesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_applyChangesButton setTitle:@"Apply" forState:UIControlStateNormal];
        _applyChangesButton.frame = CGRectMake((self.frame.size.width-b_width-10.0), (self.frame.size.height-b_height)/2.0, b_width, b_height);
        [_applyChangesButton addTarget:self action:@selector(applyChangesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_applyChangesButton];
    }
    return self;
}


- (void)backButtonPressed
{
    [_delegate algorithmViewBackButtonPressed];
}


- (void)applyChangesButtonPressed
{
    [_delegate algorithmViewApplyChangesButtonPressed];
}


#pragma mark - helper functions

// simple helper function to print the contents of a frame combined with some prefix
- (void)printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix
{
    NSString* printStr = [prefix stringByAppendingString:@" ==> x: %3.2f, y: %3.2f, w: %3.2f, h: %3.2f"];
    CGPoint origOrig = rect.origin;
    CGSize  origSize = rect.size;
    NSLog(printStr, origOrig.x, origOrig.y, origSize.width, origSize.height);
}
 

@end
