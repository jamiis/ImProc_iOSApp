//
//  OFAlgorithmAttributes.m
//  ImgProc
//
//  Created by Jamis Johnson on 4/5/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFAlgorithmAttributes.h"
#import "Constants.h"

@implementation OFAlgorithmAttributes

@synthesize currentAlgorithm = _currentAlgorithm,
            maxValue = _maxValue,
            minValue = _minValue,
            fingerInputScale = _fingerInputScale;

- (id)init
{
    if (self = [super init])
    {
        _currentAlgorithm = ALGORITHM_NONE;
    }
    return self;
}


- (void)setCurrentAlgorithm:(int)newAlgorithm
{
    _currentAlgorithm = newAlgorithm;
    
    switch (_currentAlgorithm) {
        case ALGORITHM_NONE:
            break;
        case ALGORITHM_INVERT:
            //_maxValue = ALGORITHM_MAX_VAL_;
            //_minValue = ALGORITHM_MIN_VAL_;
            break;
        case ALGORITHM_CONTRAST:
            _maxValue = ALGORITHM_MAX_VAL_CONTRAST;
            _minValue = ALGORITHM_MIN_VAL_CONTRAST;
            break;
        case ALGORITHM_BRIGHTNESS:
            _maxValue = ALGORITHM_MAX_VAL_BRIGHTNESS;
            _minValue = ALGORITHM_MIN_VAL_BRIGHTNESS;
            break;
        case ALGORITHM_THRESHOLD:
            _maxValue = ALGORITHM_MAX_VAL_THRESHOLD;
            _minValue = ALGORITHM_MIN_VAL_THRESHOLD;
            break;
        case ALGORITHM_GAMMA:
            _maxValue = ALGORITHM_MAX_VAL_GAMMA;
            _minValue = ALGORITHM_MIN_VAL_GAMMA;
            break;
        case ALGORITHM_FAST_EDGES:
            _maxValue = ALGORITHM_MAX_VAL_FAST_EDGES;
            _minValue = ALGORITHM_MIN_VAL_FAST_EDGES;
            break;
         case ALGORITHM_GAUSSIAN_BLUR:
            _maxValue = ALGORITHM_MAX_VAL_GAUSSIAN_BLUR;
            _minValue = ALGORITHM_MIN_VAL_GAUSSIAN_BLUR;
            break;
        case ALGORITHM_FAST_SHARPEN:
            _maxValue = ALGORITHM_MAX_VAL_FAST_EDGES;
            _minValue = ALGORITHM_MIN_VAL_FAST_EDGES;
            break;
        case ALGORITHM_SOBEL_EDGES:
            _maxValue = ALGORITHM_MAX_VAL_SOBEL_EDGES;
            _minValue = ALGORITHM_MIN_VAL_SOBEL_EDGES;
            break;
        case ALGORITHM_CARTOON:
            _maxValue = ALGORITHM_MAX_VAL_CARTOON;
            _minValue = ALGORITHM_MIN_VAL_CARTOON;
            break;
        case ALGORITHM_POSTERIZE:
            _maxValue = ALGORITHM_MAX_VAL_POSTERIZE;
            _minValue = ALGORITHM_MIN_VAL_POSTERIZE;
            break;
        case ALGORITHM_SKETCH:
            _maxValue = ALGORITHM_MAX_VAL_SKETCH;
            _minValue = ALGORITHM_MIN_VAL_SKETCH;
            break;
        case ALGORITHM_STATIC:
            break;
        case ALGORITHM_ERODE:
            break;
        case ALGORITHM_DILATE:
            break;
        case ALGORITHM_NOISE_REDUCTION:
            break;
    }
    
    _fingerInputScale = [self fingerInputScale];
}




- (float)fingerInputScale
{
    return 700.0/(_maxValue - _minValue);
}



@end
