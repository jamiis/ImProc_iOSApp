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
- (void)algorithmViewBackButtonPressed;
- (void)algorithmViewApplyChangesButtonPressed;
@optional
@end

@interface OFAlgorithmControlsView : UIView {
    id <OFAlgorithmControlsViewDelegate> _delegate;
    UIButton *_backButton;
    UIButton *_applyChangesButton;
}

@property (nonatomic, retain) id <OFAlgorithmControlsViewDelegate> delegate;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *applyChangesButton;

- (void)backButtonPressed;
- (void)applyChangesButtonPressed;

- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix;

@end
