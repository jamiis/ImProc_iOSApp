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
            applyChangesButton = _applyChangesButton,
            recordVideoButton = _recordVideoButton,
            inLiveVideoMode = _inLiveVideoMode,
            infoButton = _infoButton,
            helpButton = _helpButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor underPageBackgroundColor];
        
        float b_height;
        float b_width;
        
        // BACK BUTTON
        _backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_backButton setTitle:@"Back" forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backButton];
        
        // APPLY CHANGES BUTTON
        _applyChangesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_applyChangesButton setTitle:@"Apply" forState:UIControlStateNormal];
        [_applyChangesButton addTarget:self action:@selector(applyChangesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_applyChangesButton];
        
        // RECORD VIDEO BUTTON
        _recordVideoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_recordVideoButton setTitle:@"Record" forState:UIControlStateNormal];
//        [_recordVideoButton setTitle:@"Stop" forState:UIControlStateDisabled];
        [_recordVideoButton addTarget:self action:@selector(recordVideoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//        [_recordVideoButton setHidden:YES];
        [self addSubview:_recordVideoButton];
        
        // INFO BUTTON
        _infoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_infoButton setTitle:@"Info" forState:UIControlStateNormal];
        [_infoButton addTarget:self action:@selector(infoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [_infoButton setHidden:YES];
        [self addSubview:_infoButton];
        
        
        // HELP BUTTON
        _helpButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_helpButton setTitle:@"Help" forState:UIControlStateNormal];
        [_helpButton addTarget:self action:@selector(helpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_helpButton];
        
        
        // set the button positions based on the device being used
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            b_height = 30.0*1.5;
            b_width  = 60.0*1.5;

            _backButton.frame = CGRectMake(10.0, (ALGORITHM_VIEW_HEIGHT_IPAD-b_height)/2.0, b_width, b_height);            
            _applyChangesButton.frame = CGRectMake((768.0-b_width-10.0), (ALGORITHM_VIEW_HEIGHT_IPAD-b_height)/2.0, b_width, b_height);
            _recordVideoButton.frame = CGRectMake((768.0-b_width-10.0), (ALGORITHM_VIEW_HEIGHT_IPAD-b_height)/2.0, b_width, b_height);
            _infoButton.frame = CGRectMake(self.center.x-b_width/2.0, (ALGORITHM_VIEW_HEIGHT_IPAD-b_height)/2.0, b_width, b_height);
            _helpButton.frame = CGRectMake(self.center.x-b_width/2.0, (ALGORITHM_VIEW_HEIGHT_IPAD-b_height)/2.0, b_width, b_height);
        }
        else {
            b_height = 30.0;
            b_width  = 60.0;
            
            _backButton.frame = CGRectMake(10.0, (ALGORITHM_VIEW_HEIGHT-b_height)/2.0, b_width, b_height);
            _applyChangesButton.frame = CGRectMake((320.0-b_width-10.0), (ALGORITHM_VIEW_HEIGHT-b_height)/2.0, b_width, b_height);
            _recordVideoButton.frame = CGRectMake((320.0-b_width-10.0), (ALGORITHM_VIEW_HEIGHT-b_height)/2.0, b_width, b_height);
            _infoButton.frame = CGRectMake(self.center.x-b_width/2.0, (ALGORITHM_VIEW_HEIGHT-b_height)/2.0, b_width, b_height);
            _helpButton.frame = CGRectMake(self.center.x-b_width/2.0, (ALGORITHM_VIEW_HEIGHT-b_height)/2.0, b_width, b_height);  
        }
    }
    
    return self;
}




#pragma mark - Buttons Pressed Methods
- (void)backButtonPressed
{
    [_delegate algorithmViewBackButtonPressed];
}


- (void)applyChangesButtonPressed
{
    [_delegate algorithmViewApplyChangesButtonPressed];
}


- (void)recordVideoButtonPressed
{
    [_delegate algorithmViewRecordVideoButtonPressed];
}


- (void)infoButtonPressed
{
    NSLog(@"info button pressed");
}


- (void)helpButtonPressed
{
    [_delegate algorithmViewHelpButtonPressed];
}



#pragma mark - Getter Setter Overrides
- (void)setInLiveVideoMode:(BOOL)inLiveVideoMode
{
    _inLiveVideoMode = inLiveVideoMode;
    
    if (inLiveVideoMode) {
        _applyChangesButton.hidden = TRUE;
        _recordVideoButton.hidden = FALSE;
    }
    else {
        _applyChangesButton.hidden = FALSE;
        _recordVideoButton.hidden = TRUE;
    }
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
