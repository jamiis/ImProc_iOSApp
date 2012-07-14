//
//  OFInstructionImageView.m
//  ImgProc
//
//  Created by Jamis Johnson on 4/25/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFInstructionImageView.h"

@implementation OFInstructionImageView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setUserInteractionEnabled:YES];
        [self setBackgroundColor:[UIColor clearColor]];
        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            self.image = [UIImage imageNamed:@"instruction_overlay_ipad.png"];
//        }
//        else {
//            self.image = [UIImage imageNamed:@"rally.png"];
//        }
    }
    return self;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [delegate dismissInstructionImageView];
}


- (void)setImageWithTag:(NSInteger)tag
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.image = [UIImage imageNamed:@"instruction_overlay_ipad.png"];
    }
    else {
        self.image = [UIImage imageNamed:@"instruction_overlay_iphone.png"];
    }
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
