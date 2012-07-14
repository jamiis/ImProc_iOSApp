//
//  OFAlgorithmView.h
//  ImgProc
//
//  Created by Jamis Johnson on 3/10/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OFAlgorithmControlsView;

@protocol OFAlgorithmControlsViewDelegate <NSObject>
@required
- (void)algorithmViewBackButtonPressed;
- (void)algorithmViewApplyChangesButtonPressed;
- (void)algorithmViewRecordVideoButtonPressed;
- (void)algorithmViewHelpButtonPressed;
@end

@interface OFAlgorithmControlsView : UIView {
    id <OFAlgorithmControlsViewDelegate> _delegate;
    UIButton *_backButton;
    UIButton *_applyChangesButton;
    UIButton *_recordVideoButton;
    UIButton *_infoButton;
    UIButton *_helpButton;
    BOOL _inLiveVideoMode;
}

@property (nonatomic, retain) id<OFAlgorithmControlsViewDelegate> delegate;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *applyChangesButton;
@property (nonatomic, retain) UIButton *recordVideoButton;
@property (nonatomic, retain) UIButton *infoButton;
@property (nonatomic, retain) UIButton *helpButton;
@property (nonatomic) BOOL inLiveVideoMode;

- (void)backButtonPressed;
- (void)applyChangesButtonPressed;
- (void)recordVideoButtonPressed;
- (void)infoButtonPressed;
- (void)helpButtonPressed;

- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix;

@end
