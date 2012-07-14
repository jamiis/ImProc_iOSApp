//
//  OFInstructionImageView.h
//  ImgProc
//
//  Created by Jamis Johnson on 4/25/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OFInstructionImageViewDelegate;


@interface OFInstructionImageView : UIImageView {
    id<OFInstructionImageViewDelegate> delegate;
}
@property (nonatomic, assign) id<OFInstructionImageViewDelegate> delegate;
- (void)setImageWithTag:(NSInteger)tag;
@end


@protocol OFInstructionImageViewDelegate <NSObject>
@required
-(void)dismissInstructionImageView;
@end
