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
#import "ImProc_Effects.h"
#import "ImageConverter.h"
#import "UIImage-Extensions.h"

@implementation OFAlgorithmHandler

@synthesize delegate = _delegate,
            algorithm = _algorithm,
            liveVideoIsRunning = _liveVideoIsRunning,
            liveVideoIsRecording = _liveVideoIsRecording;

static int demoImageCount = 0;


#pragma mark - Lifecycle
- (id)init 
{
    if (self = [super init])
    {
        // initialization code here
        _algorithm = [OFAlgorithmAttributes alloc];
        _liveVideoIsRecording = NO;
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


- (int)getCurrentAlpha
{
    switch (_algorithm.currentAlgorithm) {
        case ALGORITHM_CONTRAST:
            return _algorithmAlphaIntCurrent;
        case ALGORITHM_INVERT:
            return -1.0;
        case ALGORITHM_BRIGHTNESS:
            return _algorithmAlphaIntCurrent;
        case ALGORITHM_THRESHOLD:
            return _algorithmAlphaIntCurrent;
        case ALGORITHM_GAMMA:
            return (int)_algorithmAlphaDoubleCurrent;
        case ALGORITHM_GRADIENT_MAGNITUDE:
            return -1.0;
        case ALGORITHM_FAST_EDGES:
            return _algorithmAlphaIntCurrent;
        case ALGORITHM_GAUSSIAN_BLUR:
            return -1.0;
        case ALGORITHM_FAST_SHARPEN:
            return -1.0;
        case ALGORITHM_SOBEL_EDGES:
            return _algorithmAlphaIntCurrent;
        case ALGORITHM_CARTOON:
            return _algorithmAlphaIntCurrent;
        case ALGORITHM_POSTERIZE:
            return _algorithmAlphaIntCurrent;
        case ALGORITHM_SKETCH:
            return _algorithmAlphaIntCurrent;
        case ALGORITHM_STATIC:
            return -1.0;
        case ALGORITHM_ERODE:
            return -1.0;
        case ALGORITHM_DILATE:
            return -1.0;
        case ALGORITHM_NOISE_REDUCTION:
            return -1.0;
            
        default:
            break;
    }
    
    return -2.0;
}




#pragma mark - Methods
- (void)processImage:(UIImage*)image
{
    // if current algorithm is DEMO algorithm, change sample pictures
    if (_algorithm.currentAlgorithm == ALGORITHM_DEMO && !_liveVideoIsRunning) 
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (demoImageCount == 0){
                [_delegate setOriginalImage:[UIImage imageNamed:@"jupiter.png"]];
                demoImageCount = 1;
            }
            else if (demoImageCount == 1){
                [_delegate setOriginalImage:[UIImage imageNamed:@"dog-frisbee.png"]];
                demoImageCount = 2;
            }
            else if (demoImageCount == 2){
                [_delegate setOriginalImage:[UIImage imageNamed:@"fruit.png"]];
                demoImageCount = 3;
            }
            else {
                [_delegate setOriginalImage:[UIImage imageNamed:@"toms.png"]];
                demoImageCount = 0;
            }
        }
        else {
            if (demoImageCount == 0){
                [_delegate setOriginalImage:[UIImage imageNamed:@"typography.png"]];
                demoImageCount = 1;
            } 
            else if (demoImageCount == 1){
                [_delegate setOriginalImage:[UIImage imageNamed:@"flatiron.png"]];
                demoImageCount = 2;
            }
            else {
                [_delegate setOriginalImage:[UIImage imageNamed:@"cassius.png"]];
                demoImageCount = 0;
            }
        }
        [_algorithm setCurrentAlgorithm:ALGORITHM_NONE];
        return;
    } 
    else if (_algorithm.currentAlgorithm == ALGORITHM_DEMO && _liveVideoIsRunning) {
        [_algorithm setCurrentAlgorithm:ALGORITHM_NONE];
        return;
    }
    
    
    // if no algorithm, no bitmap processing necessary so short-circuit
    if (_algorithm.currentAlgorithm == ALGORITHM_NONE) {
        [_delegate setOriginalImage:image];
        return;
    }
    
    // otherwise bitmap processing is necessary
    
    // width and height need to be reversed if orientation is right or left.  
    // this is an artifact of an incorrect orientation from AVFoundation
    int width  = image.size.width*image.scale;
    int height = image.size.height*image.scale;
    if (image.imageOrientation == UIImageOrientationUp || 
        image.imageOrientation == UIImageOrientationDown) {
        width  = image.size.width*image.scale;
        height = image.size.height*image.scale;
    } else {
        width = image.size.height*image.scale;
        height = image.size.width*image.scale;
    }
    
    
    // convert image to bitmap for processing
    pixel *imageBitmap = (pixel *)[ImageConverter convertUIImageToBitmapRGBA8:image];
    //printf("%i\n",(int)imageBitmap);
    pixel *newBitmap   = pixel_copy(imageBitmap, width, height);
    
    //NSLog(@"alpha int   val %i", _algorithmAlphaIntCurrent);
    //NSLog(@"alpha float val %3.2f", _algorithmAlphaDoubleCurrent);
    
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
            Fast_Edges(imageBitmap, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_GAUSSIAN_BLUR:
            Gaussian_Blur(imageBitmap, 3, width, height, 0, newBitmap);
            break;
        case ALGORITHM_FAST_SHARPEN:
            //Unsharp_Masking(imageBitmap, 5.0, _algorithmAlphaDoubleCurrent, width, height, 1, newBitmap);
            Unsharp_Masking(imageBitmap, 5.0, 0.5, width, height, 1, newBitmap);
            break;
        case ALGORITHM_SOBEL_EDGES:
            Sobel_Edges(imageBitmap, 1, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_CARTOON:
            Cartoon(imageBitmap, _algorithmAlphaIntCurrent, 7, width, height, newBitmap);
            break;
        case ALGORITHM_POSTERIZE:
            Posterize(imageBitmap, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_SKETCH:
            Sketch(imageBitmap, _algorithmAlphaIntCurrent, 120, width, height, newBitmap);
            break;
        case ALGORITHM_STATIC:
            Fast_Edges(imageBitmap, ALGORITHM_MIN_VAL_FAST_EDGES, width, height, newBitmap);
            break;
        case ALGORITHM_ERODE:
            Min_Filter(imageBitmap, width, height, newBitmap);
            break;
        case ALGORITHM_DILATE:
            Max_Filter(imageBitmap, width, height, newBitmap);
            break;
        case ALGORITHM_NOISE_REDUCTION:
            Median_Filter(imageBitmap, width, height, newBitmap);
            break;
            
        default:
            newBitmap = imageBitmap;
            break;
    }
    
    // get new UIImage from processed bitmap: newBitmap
    UIImage *newImage = [ImageConverter convertBitmapRGBA8ToUIImage:(unsigned char*)newBitmap 
                                                          withWidth:width 
                                                         withHeight:height];
    if(newBitmap != NULL) 
    {
        free(newBitmap);	
        newBitmap = NULL;
    }
    
    // cleanup
    if (imageBitmap != NULL) {
        //printf("%i\n",(int)imageBitmap);
        free(imageBitmap);	
        imageBitmap = NULL;
    }
    
    // handle special rotation cases
    switch (image.imageOrientation) {
        case UIImageOrientationUp:
            //NSLog(@"orientation is UP");
            break;
        case UIImageOrientationDown:
            //NSLog(@"orientation DOWN");
            //NSDate *now = [NSDate date];
            //NSLog(@"orientation is DOWN");
            newImage = [newImage imageRotatedByDegrees:180.0];
            //NSLog(@"duration of rotation: %3.2f", [now timeIntervalSinceNow]);
            break;
        case UIImageOrientationRight:
            //NSLog(@"orientation is RIGHT");
            newImage = [newImage imageRotatedByDegrees:90.0];
            break;
        case UIImageOrientationLeft:
            //NSLog(@"orientation is LEFT");
            newImage = [newImage imageRotatedByDegrees:270.0];
            break;
        default:
            NSLog(@"orientation NONE");
            break;
    }
    
    // set new processed image
    [_delegate setEditedImage:newImage];
}


- (void)processPixelBuffer: (CVImageBufferRef)pixelBuffer 
{
	CVPixelBufferLockBaseAddress( pixelBuffer, 0 );
	
	int width = CVPixelBufferGetWidth(pixelBuffer);
	int height = CVPixelBufferGetHeight(pixelBuffer);
    
    pixel *newBitmap = (pixel *)CVPixelBufferGetBaseAddress(pixelBuffer);
    pixel *imageBitmap = pixel_copy(newBitmap, width, height);
    
//	for( int row = 0; row < bufferHeight; row++ ) {		
//		for( int column = 0; column < bufferWidth; column++ ) {
//			pixel[1] = 0; // De-green (second pixel in BGRA is green)
//			pixel += BYTES_PER_PIXEL;
//		}
//	}
    
    
    
    // width and height need to be reversed if orientation is right or left.  
    // this is an artifact of an incorrect orientation from AVFoundation
//    int width  = image.size.width*image.scale;
//    int height = image.size.height*image.scale;
//    if (image.imageOrientation == UIImageOrientationUp || 
//        image.imageOrientation == UIImageOrientationDown) {
//        width  = image.size.width*image.scale;
//        height = image.size.height*image.scale;
//    } else {
//        width = image.size.height*image.scale;
//        height = image.size.width*image.scale;
//    }
    
    
    
    // convert image to bitmap for processing
//    pixel *imageBitmap = (pixel *)[ImageConverter convertUIImageToBitmapRGBA8:image];
    //printf("%i\n",(int)imageBitmap);
//    pixel *newBitmap   = pixel_copy(imageBitmap, width, height);
    
    //NSLog(@"alpha int   val %i", _algorithmAlphaIntCurrent);
    //NSLog(@"alpha float val %3.2f", _algorithmAlphaDoubleCurrent);
    
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
            Fast_Edges(imageBitmap, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_GAUSSIAN_BLUR:
            Gaussian_Blur(imageBitmap, 3, width, height, 0, newBitmap);
            break;
        case ALGORITHM_FAST_SHARPEN:
            //Unsharp_Masking(imageBitmap, 5.0, _algorithmAlphaDoubleCurrent, width, height, 1, newBitmap);
            Unsharp_Masking(imageBitmap, 5.0, 0.5, width, height, 1, newBitmap);
            break;
        case ALGORITHM_SOBEL_EDGES:
            Sobel_Edges(imageBitmap, 1, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_CARTOON:
            Cartoon(imageBitmap, _algorithmAlphaIntCurrent, 7, width, height, newBitmap);
            break;
        case ALGORITHM_POSTERIZE:
            Posterize(imageBitmap, _algorithmAlphaIntCurrent, width, height, newBitmap);
            break;
        case ALGORITHM_SKETCH:
            Sketch(imageBitmap, _algorithmAlphaIntCurrent, 120, width, height, newBitmap);
            break;
        case ALGORITHM_STATIC:
            Fast_Edges(imageBitmap, ALGORITHM_MIN_VAL_FAST_EDGES, width, height, newBitmap);
            break;
        case ALGORITHM_ERODE:
            Min_Filter(imageBitmap, width, height, newBitmap);
            break;
        case ALGORITHM_DILATE:
            Max_Filter(imageBitmap, width, height, newBitmap);
            break;
        case ALGORITHM_NOISE_REDUCTION:
            Median_Filter(imageBitmap, width, height, newBitmap);
            break;
            
        default:
            //newBitmap = imageBitmap;
            break;
    }
    
    // get new UIImage from processed bitmap: newBitmap
//    UIImage *newImage = [ImageConverter convertBitmapRGBA8ToUIImage:(unsigned char*)newBitmap 
//                                                          withWidth:width 
//                                                         withHeight:height];
    
    // handle special rotation cases
//    switch (image.imageOrientation) {
//        case UIImageOrientationUp:
//            //NSLog(@"orientation is UP");
//            break;
//        case UIImageOrientationDown:
//            //NSLog(@"orientation DOWN");
//            //NSDate *now = [NSDate date];
//            //NSLog(@"orientation is DOWN");
//            newImage = [newImage imageRotatedByDegrees:180.0];
//            //NSLog(@"duration of rotation: %3.2f", [now timeIntervalSinceNow]);
//            break;
//        case UIImageOrientationRight:
//            //NSLog(@"orientation is RIGHT");
//            newImage = [newImage imageRotatedByDegrees:90.0];
//            break;
//        case UIImageOrientationLeft:
//            //NSLog(@"orientation is LEFT");
//            newImage = [newImage imageRotatedByDegrees:270.0];
//            break;
//        default:
//            NSLog(@"orientation NONE");
//            break;
//    }
    
    // set new processed image
//    [_delegate setEditedImage:newImage];
    
    // set the pixelBuffer (aka imageBitmap) to the newBitmap
//	imageBitmap = newBitmap;
    
	CVPixelBufferUnlockBaseAddress( pixelBuffer, 0 );
    
    //TODO: CHECK FOR MEMORY LEAKS! IE. NEWBITMAP, IMAGEBITMAP
    
//    if(newBitmap != NULL) 
//    {
//        free(newBitmap);
//        newBitmap = NULL;
//    }
    
    // cleanup
    if (imageBitmap != NULL) {
        //printf("%i\n",(int)imageBitmap);
        free(imageBitmap);	
        imageBitmap = NULL;
    }
}


// adjust alpha based on finger movement and 
// ensure new alpha value is within algorithm max and min limits
- (void) adjustAlgorithmAlpha:(float)translatedX
{
    // handle changing int alpha
    _algorithmAlphaIntCurrent = _algorithmAlphaIntPrevious + (int)(translatedX/_algorithm.fingerInputScale);
    if (_algorithmAlphaIntCurrent > _algorithm.maxValue) {
        _algorithmAlphaIntCurrent = _algorithm.maxValue;
    }
    else if (_algorithmAlphaIntCurrent < _algorithm.minValue) {
        _algorithmAlphaIntCurrent = _algorithm.minValue;
    }
    
    // handle double alpha
    _algorithmAlphaDoubleCurrent = _algorithmAlphaDoublePrevious + (int)(translatedX/_algorithm.fingerInputScale);
    if (_algorithmAlphaDoubleCurrent > _algorithm.maxValue) {
        _algorithmAlphaDoubleCurrent = _algorithm.maxValue;
    }
    else if (_algorithmAlphaDoubleCurrent < _algorithm.minValue) {
        _algorithmAlphaDoubleCurrent = _algorithm.minValue;
    }
}


- (void)finishedAdjustingAlgorithmAlpha
{
    _algorithmAlphaIntPrevious = _algorithmAlphaIntCurrent;
    _algorithmAlphaDoublePrevious = _algorithmAlphaDoubleCurrent;
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
        case ALGORITHM_FAST_SHARPEN:
            _algorithmAlphaDoubleCurrent = ALGORITHM_INIT_VAL_FAST_SHARPEN;
            break;
        case ALGORITHM_SOBEL_EDGES:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_SOBEL_EDGES;
            break;
        case ALGORITHM_CARTOON:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_CARTOON;
            break;
        case ALGORITHM_POSTERIZE:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_POSTERIZE;
            break;
        case ALGORITHM_SKETCH:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_SKETCH;
            break;
        /*
        case ALGORITHM_ERODE:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_ERODE;
            break;
        case ALGORITHM_DILATE:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_DILATE;
            break;
        case ALGORITHM_NOISE_REDUCTION:
            _algorithmAlphaIntCurrent = ALGORITHM_INIT_VAL_NOISE_REDUCTION;
            break;
        */
    }
    
    _algorithmAlphaIntPrevious = _algorithmAlphaIntCurrent;
    _algorithmAlphaDoublePrevious = _algorithmAlphaDoubleCurrent;
}



@end
