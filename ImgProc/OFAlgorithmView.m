//
//  OFAlgorithmView.m
//  ImgProc
//
//  Created by Jamis Johnson on 3/10/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFAlgorithmView.h"

@implementation OFAlgorithmView

@synthesize backButton = _backButton, 
            delegate = _delegate, 
            applyChangesButton = _applyChangesButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        // BACK BUTTON
        _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        float b_dim = 30.0;
        _backButton.frame = CGRectMake(10.0, (self.frame.size.height-b_dim)/2.0, b_dim, b_dim);
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        // APPLY CHANGES BUTTON
        _applyChangesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        float a_dim = 30.0;
        _applyChangesButton.frame = CGRectMake((self.frame.size.width-a_dim-10.0), (self.frame.size.height-a_dim)/2.0, a_dim, a_dim);
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
