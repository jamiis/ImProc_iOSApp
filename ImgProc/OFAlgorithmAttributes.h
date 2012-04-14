//
//  OFAlgorithmAttributes.h
//  ImgProc
//
//  Created by Jamis Johnson on 4/5/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OFAlgorithmAttributes : NSObject {
    int _currentAlgorithm;
    int _maxValue;
    int _minValue;
    float _fingerInputScale;
}

@property (nonatomic) int currentAlgorithm;
@property (nonatomic) int maxValue;
@property (nonatomic) int minValue;
@property (nonatomic) float fingerInputScale;

- (float) fingerInputScale;

@end
