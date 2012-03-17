//
//  OFAlgorithmView.h
//  ImgProc
//
//  Created by Jamis Johnson on 3/10/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "Constants.h"
#import <UIKit/UIKit.h>

@class OFAlgorithmView;

@protocol OFAlgorithmViewDelegate <NSObject>
- (void)algorithmViewBackButtonPressed;
- (void)algorithmViewApplyChangesButtonPressed;
@optional
@end

@interface OFAlgorithmView : UIView {
    id <OFAlgorithmViewDelegate> _delegate;
    UIButton *_backButton;
    UIButton *_applyChangesButton;
}

@property (nonatomic, retain) id <OFAlgorithmViewDelegate> delegate;
@property (nonatomic, retain) UIButton *backButton;
@property (nonatomic, retain) UIButton *applyChangesButton;

- (void)backButtonPressed;
- (void)applyChangesButtonPressed;

- (void) printContentsOfFrame:(CGRect)rect withPrefixString:(NSString*)prefix;

@end
