//
//  OFAlgorithmHandler.h
//  ImgProc
//
//  Created by Jamis Johnson on 4/5/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OFAlgorithmAttributes.h"

@class OFAlgorithmHandler;

@protocol OFAlgorithmHandlerDelegate <NSObject>
- (void)setOriginalImage:(UIImage*)image;
- (void)setEditedImage:(UIImage*)image;
@required
@end

@interface OFAlgorithmHandler : NSObject {
    id<OFAlgorithmHandlerDelegate> _delegate;
    OFAlgorithmAttributes *_algorithm;
    
    int _algorithmAlphaIntCurrent;
    int _algorithmAlphaIntPrevious;
    double _algorithmAlphaDoubleCurrent;
    double _algorithmAlphaDoublePrevious;

    BOOL _liveVideoIsRunning;
}

@property (nonatomic, retain) id<OFAlgorithmHandlerDelegate> delegate;
@property (nonatomic, retain) OFAlgorithmAttributes *algorithm;
@property (nonatomic) BOOL liveVideoIsRunning;

- (void)setCurrentAlgorithm:(int)newAlgorithm;
- (int)getCurrentAlgorithm;
- (void)processImage:(UIImage*)image;
- (void)adjustAlgorithmAlpha:(float)translatedX;
- (void)finishedAdjustingAlgorithmAlpha;
- (void)setInitialAlpha;

@end
