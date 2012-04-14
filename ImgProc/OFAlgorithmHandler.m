//
//  OFAlgorithmHandler.m
//  ImgProc
//
//  Created by Jamis Johnson on 4/5/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import "OFAlgorithmHandler.h"
#import "Constants.h"
#import "ImProc_Base.h"
#import "ImProc_Filters.h"
#import "ImProc_Edges.h"
#import "ImageConverter.h"

@implementation OFAlgorithmHandler

@synthesize delegate = _delegate,
            algorithm = _algorithm,
            liveVideoIsRunning = _liveVideoIsRunning;

static int demoImageCount = 0;


#pragma mark - Lifecycle
- (id)init 
{
    NSLog(@"Algorithm handler is being init'd");
    if (self = [super init])
    {
        // initialization code here
        _algorithm = [OFAlgorithmAttributes alloc];
    }
    return self;
}


- (void)dealloc
{
    [_delegate release];
    [_algorithm release];
    
    [super dealloc];
}




#pragma mark - Getters and Setters
- (void)setCurrentAlgorithm:(int)newAlgorithm
{
    [_algorithm setCurrentAlgorithm:newAlgorithm];
    
}

- (int)getCurrentAlgorithm
{
    return _algorithm.currentAlgorithm;
}




#pragma mark - Methods
- (void)processImage:(UIImage*)image
{
    // if current algorithm is DEMO algorithm, change sample pictures
    if (_algorithm.currentAlgorithm >= ALGORITHM_DEMO && !_liveVideoIsRunning) {
        if (demoImageCount == 0){
            [_delegate setOriginalImage:[UIImage imageNamed:@"flatiron.png"]];
            NSLog(@"flatiron w: %3.2f, h: %3.2f", [UIImage imageNamed:@"flatiron.png"].size.width,[UIImage imageNamed:@"flatiron.png"].size.height);
            demoImageCount = 1;
        } 
        else {
            [_delegate setOriginalImage:[UIImage imageNamed:@"cassius.jpg"]];
            NSLog(@"cassius w: %3.2f, h: %3.2f", [UIImage imageNamed:@"cassius.jpg"].size.width,[UIImage imageNamed:@"cassius.jpg"].size.height);
            demoImageCount = 0;
        }
        [_algorithm setCurrentAlgorithm:ALGORITHM_NONE];
        return;
    }
    
    // if no algorithm, no bitmap processing necessary so short-circuit
    if (_algorithm.currentAlgorithm == ALGORITHM_NONE) {
        [_delegate setOriginalImage:image];
        return;
    }
    
    // otherwise bitmap processing is necessary
    int width  = image.size.width*image.scale;
    int height = image.size.height*image.scale;
    
//    if (image.scale == 2.0) {
//        width = width*2.0;
//        height = height*2.0;
//    }
    
    NSLog(@"process image w: %i, h: %i, orientation: %i", width, height, image.imageOrientation);
    
    // convert incoming image to bitmap
    pixel *imageBitmap = (pixel *)[ImageConverter convertUIImageToBitmapRGBA8:image];
    pixel *newBitmap   = (pixel *) malloc(sizeof(pixel) * width * height);
    
//    NSLog(@"new alpha: %i", _algorithmAlphaIntCurrent);
    
    switch (_algorithm.currentAlgorithm) {
        case ALGORITHM_CONTRAST:
            Modify_Contrast(imageBitmap, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_INVERT:
            Invert_Pixels(imageBitmap, width, height, newBitmap);
            break;
        case ALGORITHM_BRIGHTNESS:
            Modify_Brightness(imageBitmap, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_THRESHOLD:
            Threshold(RGB_to_Gray_PixelArray(imageBitmap,width,height,imageBitmap), _algorithmAlphaIntCurrent, width, height, newBitmap);
            //Threshold(imageBitmap, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_GAMMA:
            Gamma_Corr(imageBitmap, _algorithmAlphaDoubleCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_GRADIENT_MAGNITUDE:
            Gradient_Magnitude(imageBitmap, _algorithmAlphaDoubleCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_FAST_EDGES:
            //Fast_Edges(imageBitmap, _algorithmAlphaIntCurrent, width, height, newBitmap);
            //Sobel_Edges(imageBitmap, 150, _algorithmAlphaIntCurrent, width, height, newBitmap);
            Prewitt_Edges(imageBitmap, 7, 1, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_GAUSSIAN_BLUR:
            //Gaussian_Blur(imageBitmap, 3, width, height, 0, newBitmap);
            //Fast_Blur_Color(imageBitmap, 4, width, height, newBitmap);
            Fast_Blur_Gray(imageBitmap, 4, width, height, newBitmap);
            break;
        case ALGORITHM_FAST_SHARPEN:
            Fast_Sharpen(imageBitmap, width, height, newBitmap);
            break;
        default:
            newBitmap = imageBitmap;
            break;
    }
    
    [_delegate setEditedImage:[ImageConverter convertBitmapRGBA8ToUIImage:(unsigned char*)newBitmap 
                                                                withWidth:width 
                                                                withHeight:height]];
    
    // cleanup
    if(imageBitmap) {
        free(imageBitmap);	
        imageBitmap = NULL;
    }
    if(newBitmap) {
        free(newBitmap);	
        newBitmap = NULL;
     }
}



- (void) adjustAlgorithmAlpha:(float)translatedX
{
    _algorithmAlphaIntCurrent = _algorithmAlphaIntPrevious + (int)(translatedX/_algorithm.fingerInputScale);
    
    // ensure new alpha value is within algorithm limits
    if (_algorithmAlphaIntCurrent > _algorithm.maxValue) {
        _algorithmAlphaIntCurrent = _algorithm.maxValue;
    }
    else if (_algorithmAlphaIntCurrent < _algorithm.minValue) {
        _algorithmAlphaIntCurrent = _algorithm.minValue;
    }
    
    //TODO: adapt for float values
}


- (void)finishedAdjustingAlgorithmAlpha
{
    _algorithmAlphaIntPrevious = _algorithmAlphaIntCurrent;
}


- (void)setInitialAlpha
{
    // set initial algorithm value
    switch (_algorithm.currentAlgorithm) {
        case ALGORITHM_NONE:
            break;
        case ALGORITHM_INVERT:
            break;
        case ALGORITHM_CONTRAST:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_CONTRAST;
            break;
        case ALGORITHM_BRIGHTNESS:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_BRIGHTNESS;
            break;
        case ALGORITHM_THRESHOLD:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_THRESHOLD;
            break;
        case ALGORITHM_GAMMA:
            _algorithmAlphaDoubleCurrent = ALGORITHM_INIT_VAL_GAMMA;
            break;
        case ALGORITHM_GRADIENT_MAGNITUDE:
            _algorithmAlphaDoubleCurrent = ALGORITHM_INIT_VAL_GRADIENT_MAGNITUDE;
            break;
        case ALGORITHM_FAST_EDGES:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_FAST_EDGES;
            break;
        case ALGORITHM_GAUSSIAN_BLUR:
            _algorithmAlphaDoubleCurrent = ALGORITHM_INIT_VAL_GAUSSIAN_BLUR;
            break;
    }
    _algorithmAlphaIntPrevious = _algorithmAlphaIntCurrent;
}



@end
