// Nathan Wingert - u0687928
// Image Processing Library Test Source
// Converting to pixels, testing

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "ImProc.h"

#define MIN3(x,y,z)  ((y) <= (z) ? \
((x) <= (y) ? (x) : (y)) \
: \
((x) <= (z) ? (x) : (z)))

#define MAX3(x,y,z)  ((y) >= (z) ? \
((x) >= (y) ? (x) : (y)) \
: \
((x) >= (z) ? (x) : (z)))

#define FLOAT	0
#define INT 	1
#define ADD		0
#define SUB		1
#define MUL		2
#define DIV		3

// grayscale point operations
unsigned char* Invert_Pixels_Gray(unsigned char* image, int width, int height)
{
    int i = 0;      
    int length = width * height;
    
    for(i; i < length; i++)
    {
        image[i] = 255 - image[i];
    }
    return image;
}
//
//unsigned char* Modify_Brightness_Gray(unsigned char* image, int alpha, int width, int height)
//{
//    int i = 0;
//    int length = width * height;
//    
//    for(i; i < length; i++)
//    {
//        // compute new pixel data
//        unsigned char newGray = image[i] + alpha;
//        
//        // clamp pixel data to 0/255 (assuming 8 bit depth)
//        image[i] = (newGray > 255) ? 255 : newGray;
//    }
//    return image;
//}
//
//unsigned char* Modify_Contrast_Gray(unsigned char* image, int alpha, int width, int height)
//{
//    int i = 0;
//    int length = width * height;
//    
//    for(i; i < length; i++)
//    {
//        // compute new pixel data
//        unsigned char newGray = image[i] * alpha;
//        
//        // clamp pixel data to 0/255 (assuming 8 bit depth)
//        image[i] = (newGray > 255) ? 255 : newGray;
//    }
//    return image;
//}
//
//
//unsigned char* Threshold_Gray(unsigned char* image, int alpha, int width, int height)
//{
//    int i = 0;
//    int length = width * height;
//    
//    for(i; i < length; i++)
//    {
//        // compute new pixel data
//        unsigned char newPixel = image[i];
//        
//        // clamp pixel data to 0/255 (assuming 8 bit depth)
//        image[i] = (newPixel >= alpha) ? 255 : 0;
//    }
//    return image;
//}
//
//unsigned char* Gamma_Corr_Gray(unsigned char* image, double alpha,  int width, int height)
//{
//    int i, a;
//    i = a = 0;
//    int length = width * height;
//    
//    int K = 256;
//    int aMax = K - 1;
//    double GAMMA = alpha;
//    
//    unsigned char lookupTable[K];
//    
//    // compute lookup table
//    for(a = 0; a < K; a++)
//    {
//        double aa = (double) a / aMax;
//        double bb = pow(aa, GAMMA);
//        
//        unsigned char b = (unsigned char) round(bb * aMax);
//        lookupTable[a] = b;
//    }
//    
//    for(i; i < length; i++)
//    {
//        // apply lookup table to image
//        image[i] = lookupTable[image[i]];
//    }
//    return image;
//}
//
//// RGBA point operations
//// WARNING: some of these operations are not properly defined for color images
//
pixel* Invert_Pixels_D(pixel* image, int width, int height)
{
    int i = 0;      
    int length = width * height;
    
    for(i; i < length; i++)
    {
        pixel p = image[i];
        p.red = 255 - p.red;
        p.green = 255 - p.green;
        p.blue = 255 - p.blue;
        image[i] = p;
    }
    return image;
}

pixel* Modify_Brightness_D(pixel* image, int alpha, int width, int height)
{
    int i = 0;
    int length = width * height;
    short tempRed, tempGreen, tempBlue;
    tempRed = tempGreen = tempBlue = 0;
    
    for(i; i < length; i++)
    {
        
        // compute new pixel data
        pixel p = image[i];
        
        tempRed = p.red + alpha;
        tempGreen = p.green + alpha;
        tempBlue = p.blue + alpha;
        
        // clamp pixel data to 0/255 (assuming 8 bit depth)
        if(tempRed > 255)
            tempRed = 255;
        if(tempRed < 0)
            tempRed = 0;
        if(tempGreen > 255)
            tempGreen = 255;
        if(tempGreen < 0)
            tempGreen = 0;
        if(tempBlue > 255)
            tempBlue = 255;
        if(tempBlue < 0)
            tempBlue = 0;
        
        p.red = (unsigned char)tempRed;
        p.green = (unsigned char)tempGreen;
        p.blue = (unsigned char)tempBlue;
        
        image[i] = p;
    }
    return image;
}

pixel* Modify_Contrast_D(pixel* image, int alpha, int width, int height)
{
    int i = 0;
    int length = width * height;
    short tempRed, tempGreen, tempBlue;
    tempRed = tempGreen = tempBlue = 0;
    
    for(i; i < length; i++)
    {
        
        // compute new pixel data
        pixel p = image[i];
        
        
        tempRed = p.red * alpha;
        tempGreen = p.green * alpha;
        tempBlue = p.blue * alpha;
        
        // clamp pixel data to 0/255 (assuming 8 bit depth)
        if(tempRed > 255)
            tempRed = 255;
        if(tempRed < 0)
            tempRed = 0;
        if(tempGreen > 255)
            tempGreen = 255;
        if(tempGreen < 0)
            tempGreen = 0;
        if(tempBlue > 255)
            tempBlue = 255;
        if(tempBlue < 0)
            tempBlue = 0;
        
        p.red = (unsigned char)tempRed;
        p.green = (unsigned char)tempGreen;
        p.blue = (unsigned char)tempBlue;
        
        image[i] = p;
    }
    return image;
}

pixel* Threshold_D(pixel* image, int alpha, int width, int height)
{
    int i = 0;
    int length = width * height;
    
    for(i; i < length; i++)
    {
        // compute new pixel data
        pixel p = image[i];
        
        // clamp pixel data to 0/255 (assuming 8 bit depth)
        p.red = (p.red > alpha) ? 255 : 0;
        p.green = (p.green > alpha) ? 255 : 0;
        p.blue = (p.blue > alpha) ? 255 : 0;
        
        // assign new pixel info
        image[i] = p;
    }
    return image;
}

pixel* Gamma_Corr_D(pixel* image, double alpha,  int width, int height)
{
    int i, a;
    i = a = 0;
    int length = width * height;
    
    int K = 256;
    int aMax = K - 1;
    double GAMMA = alpha;
    
    short lookupTable[K];
    
    // compute lookup table
    for(a = 0; a < K; a++)
    {
        double aa = (double) a / aMax;
        double bb = pow(aa, GAMMA);
        
        short b = (short) round(bb * aMax);
        lookupTable[a] = b;
    }
    
    pixel p;
    for(i; i < length; i++)
    {
        // apply lookup table to image
        p = image[i];
        p.red = lookupTable[p.red];
        p.green = lookupTable[p.green];
        p.blue = lookupTable[p.blue];
        image[i] = p;
    }
    return image;
}

//pixel* Modify_Alpha_D(pixel* image, int alpha, int width, int height)
//{
//    int i = 0;
//    int length = width * height;
//    
//    for(i; i < length; i++)
//    {
//        image[i].alpha += alpha;
//    }
//    return image;
//}
//
//pixel* Modify_Contrast_ND(pixel* image, int alpha, int width, int height, pixel* output)
//{
//    int i = 0;
//    int length = width * height;
//    short tempRed, tempGreen, tempBlue;
//    tempRed = tempGreen = tempBlue = 0;
//    
//    for(i; i < length; i++)
//    {
//        
//        // compute new pixel data
//        pixel p = image[i];
//        
//        tempRed = p.red * alpha;
//        tempGreen = p.green * alpha;
//        tempBlue = p.blue * alpha;
//        
//        // clamp pixel data to 0/255 (assuming 8 bit depth)
//        if(tempRed > 255)
//            tempRed = 255;
//        if(tempRed < 0)
//            tempRed = 0;
//        if(tempGreen > 255)
//            tempGreen = 255;
//        if(tempGreen < 0)
//            tempGreen = 0;
//        if(tempBlue > 255)
//            tempBlue = 255;
//        if(tempBlue < 0)
//            tempBlue = 0;
//        
//        p.red = (unsigned char)tempRed;
//        p.green = (unsigned char)tempGreen;
//        p.blue = (unsigned char)tempBlue;
//        
//        output[i] = p;
//    }
//    return output;
//}
//
//pixel* Modify_Brightness_ND(pixel* image, int alpha, int width, int height, pixel* output)
//{
//    int i = 0;
//    int length = width * height;
//    short tempRed, tempGreen, tempBlue;
//    tempRed = tempGreen = tempBlue = 0;
//    
//    for(i; i < length; i++)
//    {
//        
//        // compute new pixel data
//        pixel p = image[i];
//        
//        tempRed = p.red + alpha;
//        tempGreen = p.green + alpha;
//        tempBlue = p.blue + alpha;
//        
//        // clamp pixel data to 0/255 (assuming 8 bit depth)
//        if(tempRed > 255)
//            tempRed = 255;
//        if(tempRed < 0)
//            tempRed = 0;
//        if(tempGreen > 255)
//            tempGreen = 255;
//        if(tempGreen < 0)
//            tempGreen = 0;
//        if(tempBlue > 255)
//            tempBlue = 255;
//        if(tempBlue < 0)
//            tempBlue = 0;
//        
//        p.red = (unsigned char)tempRed;
//        p.green = (unsigned char)tempGreen;
//        p.blue = (unsigned char)tempBlue;
//        
//        output[i] = p;
//    }
//    return output;
//}
//
//pixel* Threshold_ND(pixel* image, int alpha, int width, int height, pixel* output)
//{
//    int i = 0;
//    int length = width * height;
//    
//    for(i; i < length; i++)
//    {
//        // compute new pixel data
//        pixel p = image[i];
//        
//        // clamp pixel data to 0/255 (assuming 8 bit depth)
//        p.red = (p.red > alpha) ? 255 : 0;
//        p.green = (p.green > alpha) ? 255 : 0;
//        p.blue = (p.blue > alpha) ? 255 : 0;
//        
//        // assign new pixel info
//        output[i] = p;
//    }
//    return output;
//}
//
//pixel* Gamma_Corr_ND(pixel* image, double alpha, int width, int height, pixel* output)
//{
//    int i, a;
//    i = a = 0;
//    int length = width * height;
//    
//    int K = 256;
//    int aMax = K - 1;
//    double GAMMA = alpha;
//    
//    short lookupTable[K];
//    
//    // compute lookup table
//    for(a = 0; a < K; a++)
//    {
//        double aa = (double) a / aMax;
//        double bb = pow(aa, GAMMA);
//        
//        short b = (short) round(bb * aMax);
//        lookupTable[a] = b;
//    }
//    
//    pixel p;
//    for(i; i < length; i++)
//    {
//        // apply lookup table to image
//        p = image[i];
//        p.red = lookupTable[p.red];
//        p.green = lookupTable[p.green];
//        p.blue = lookupTable[p.blue];
//        output[i] = p;
//    }
//    return output;
//}
//
//pixel* Modify_Alpha_ND(pixel* image, int alpha, int width, int height, pixel* output)
//{
//	int i = 0;
//	int length = width * height;
//    
//	for(i; i < length; i++)
//	{
//		pixel p = image[i];
//		p.alpha += alpha;
//		output[i] = p;
//	}
//	return output;
//}
//
///*
// // automatic contrast "enhancement" methods
// // !! these methods are not properly defined for color images
// // for grayscale images, simply set one gray value for each pixel
// // no separate grayscale methods since these methods are not "real-time" and so
// // efficiency is not a major concern
// 
// pixel* Auto_Contrast(pixel* image, int width, int height)
// {
// int i;
// unsigned char r_low, r_high, g_low, g_high, b_low, b_high;
// i = r_low = r_high = g_low = g_high = b_low = b_high = 0;
// int length = width * height;
// 
// // allocate memory for "2d" histogram
// unsigned long** histogram = malloc(3*sizeof(long*));
// for(i = 0; i < 3; i++)
// {
// histogram[i] = (long*)malloc(256*sizeof(long));
// }
// 
// // initialize histogram
// for(i = 0; i < 256; i++)
// {
// histogram[0][i] = 0;
// histogram[1][i] = 0;
// histogram[2][i] = 0;
// }
// Histogram_RGB(image, width, height, histogram);
// 
// // get low r value
// i = 0;
// while(r_low == 0){
// if(histogram[0][i] != 0) r_low = i;
// i++;
// }
// 
// // get high r value
// i = 0;
// while(r_high == 0){
// if(histogram[0][255-i] != 0) r_high = 255-i;
// i++;
// }
// 
// // get low g value
// i = 0;
// while(g_low == 0){
// if(histogram[1][i] != 0) g_low = i;
// i++;
// }
// 
// // get high g value
// i = 0;
// while(g_high == 0){
// if(histogram[1][255-i] != 0) g_high = 255-i;
// i++;
// }
// 
// // get low b value
// i = 0;
// while(b_low == 0){
// if(histogram[2][i] != 0) b_low = i;
// i++;
// }
// 
// // get high b value
// i = 0;
// while(b_high == 0){
// if(histogram[2][255-i] != 0) b_high = 255-i;
// i++;
// }
// 
// for(i = 0; i < length; i++)
// {
// // compute new pixel data
// pixel newPixel;
// pixel oldPixel = image[i];
// 
// // red values
// newPixel.red = oldPixel.red - r_low;
// newPixel.red = newPixel.red * (255.0/(r_high-r_low));
// 
// // green values
// newPixel.green = oldPixel.green - g_low;
// newPixel.green = newPixel.green * (255.0/(g_high-g_low));
// 
// // blue values
// newPixel.blue = oldPixel.blue - b_low;
// newPixel.blue = newPixel.blue * (255.0/(b_high-b_low));
// 
// image[i] = newPixel;
// }
// 
// free(histogram);
// return image;
// }
// 
// pixel* Histogram_Eq(pixel* image, int width, int height)
// {
// int i;
// int length = width * height;
// 
// // allocate memory for "2d" histogram
// unsigned long** histogram = malloc(3*sizeof(long*));
// for(i = 0; i < 3; i++)
// {
// histogram[i] = malloc(256*sizeof(long));
// }
// 
// // initialize histogram
// for(i = 0; i < 256; i++)
// {
// histogram[0][i] = 0;
// histogram[1][i] = 0;
// histogram[2][i] = 0;
// }
// 
// Cum_Histogram_RGB(image, width, height, histogram);
// 
// for(i = 0; i < length; i++)
// {
// pixel* oldPixel = &image[i];
// 
// oldPixel->red = round(histogram[0][oldPixel->red] * (255.0/length));
// oldPixel->green = round(histogram[1][oldPixel->green] * (255.0/length));
// oldPixel->blue = round(histogram[2][oldPixel->blue] * (255.0/length));
// }
// for(i = 0; i < length; i++)
// {
// pixel* oldPixel = &image[i];
// unsigned long test = histogram[0][i];
// oldPixel->red = 0;
// 
// }
// 
// free(histogram);
// return image;
// }
// 
// */
//
//// analysis
//unsigned long* Histogram_Lum(pixel* image, int width, int height, unsigned long* histogram)
//{
//    int i = 0;
//    int length = width * height;
//    
//    // convert to grayscale
//    unsigned char* lum = malloc(length*sizeof(char));
//    RGB_to_Gray_CharArray(image, width, height, lum);
//    
//    for(i; i < length; i++)
//    {
//        unsigned char newGray = lum[i];
//        histogram[newGray] = histogram[newGray] + 1;
//    }
//    
//    free(lum);
//    return histogram;
//}
//
//// color histogram with individual color information and luminosity
//unsigned long** Histogram_Color(pixel* image, int width, int height, unsigned long** histogram)
//{
//    int i = 0;
//    int length = width * height;
//    
//    // convert to grayscale for intensity values
//    unsigned char* lum = malloc(length*sizeof(char));
//    RGB_to_Gray_CharArray(image, width, height, lum);
//    
//    for(i; i < length; i++)
//    {
//        pixel p = image[i];
//        unsigned char gray = lum[i];
//        
//        // get pixel values
//        unsigned char red = p.red;
//        unsigned char green = p.green;
//        unsigned char blue = p.blue;
//        
//        histogram[0][gray] = histogram[0][gray] + 1;
//        histogram[1][red] = histogram[1][red] + 1;
//        histogram[2][green] = histogram[2][green] + 1;
//        histogram[3][blue] = histogram[3][blue] + 1;
//    }
//    
//    free(lum);
//    return histogram;
//}
//
//// cumulative histograms should follow the same usage procedures as regular histograms
//unsigned long* Cum_Histogram_Lum(pixel* image, int width, int height, unsigned long* histogram)
//{
//    int i = 0;
//    int length = width * height;
//    
//    Histogram_Lum(image, width, height, histogram);
//    
//    for(i = 1; i < length; i++)
//    {
//        histogram[i] = histogram[i-1];
//    }
//    
//    return histogram;
//}
//
//unsigned long** Cum_Histogram_Color(pixel* image, int width, int height, unsigned long** histogram)
//{
//    int i;
//    int length = width * height;
//    
//    Histogram_Color(image, width, height, histogram);
//    
//    for(i = 1; i < 255; i++)
//    {
//        histogram[0][i] = histogram[0][i-1] + histogram[0][i];
//        histogram[1][i] = histogram[1][i-1] + histogram[1][i];
//        histogram[2][i] = histogram[2][i-1] + histogram[2][i];
//        histogram[3][i] = histogram[3][i-1] + histogram[3][i];
//    }
//    
//    return histogram;
//}
//
//// utility methods
//// RGB to grayscale conversion 1:
//// Original pixel array is not modified; grayscale array is updated with correct grayscale values
//// Use this if you want a smaller grayscale image representation
//unsigned char* RGB_to_Gray_CharArray(pixel* image, int width, int height, unsigned char* gray_Image)
//{
//    int i, length;
//    i = length = 0;
//    for(i; i < length; i++)
//    {
//        pixel oldPixel = image[i];
//        unsigned char newGray = 0;
//        newGray = (oldPixel.red*0.30) + (oldPixel.green*0.59) + (oldPixel.blue*0.11);
//        gray_Image[i] = newGray;
//    }
//}
//
//// RGB to grayscale conversion 2:
//// Original pixel array is modified with grayscale values for each pixel
//// Use this if you want to convert to grayscale but maintain the original image data structure
//pixel* RGB_to_Gray_PixelArray(pixel* image, int width, int height)
//{
//    int i, length;
//    i = length = 0;
//    length = width * height;
//    for(i; i < length; i++)
//    {
//        pixel oldPixel = image[i];
//        unsigned char newGray = 0;
//        newGray = (oldPixel.red*0.30) + (oldPixel.green*0.59) + (oldPixel.blue*0.11);
//        oldPixel.red = newGray;
//        oldPixel.green = newGray;
//        oldPixel.blue = newGray;
//        image[i] = oldPixel;
//    }
//    return image;
//}
//
//// RGB-HSV conversion routines
//hsv_pixel* image_rgb_to_hsv(pixel* rgb_image, int width, int height, hsv_pixel* hsv_image)
//{
//    int i = 0;
//    int length = width * height;
//    
//    for(i; i < length; i++)
//    {
//        hsv_image[i] = pixel_rgb_to_hsv(&rgb_image[i]);
//    }
//    return hsv_image;
//}
//
//hsv_pixel pixel_rgb_to_hsv(pixel* rgb)
//{
//    hsv_pixel hsv;
//    hsv.hue = 0;
//    hsv.sat = 0;
//    hsv.val = 0;
//    
//    unsigned char r,g,b;
//    r = rgb->red;
//    g = rgb->green;
//    b = rgb->blue;
//    
//    double cMax = 255.0;
//    unsigned char cHi = MAX3(r, g, b);
//    unsigned char cLo = MIN3(r, g, b);
//    unsigned char cRng = cHi - cLo;
//    
//    hsv.val = cHi/cMax;
//    
//    if(cHi > 0)
//        hsv.sat = (double)cRng/cHi;
//    
//    if(cRng > 0)
//    {
//        double rr = (double)(cHi - r) / cRng;
//        double gg = (double)(cHi - g) / cRng;
//        double bb = (double)(cHi - b) / cRng;
//        double hh;
//        if (r == cHi)                      // r is highest color value
//            hh = bb - gg;
//        else if (g == cHi)                 // g is highest color value
//            hh = rr - bb + 2.0;
//        else                               // b is highest color value
//            hh = gg - rr + 4.0;
//        if (hh < 0)
//            hh= hh + 6;
//        hsv.hue = hh / 6;
//    }
//    
//    return hsv;
//}
//
//pixel* image_hsv_to_rgb(hsv_pixel* hsv_image, int width, int height, pixel* rgb_image)
//{
//    int i = 0;
//    int length = width * height;
//    
//    for(i; i < length; i++)
//    {
//        rgb_image[i] = pixel_hsv_to_rgb(&hsv_image[i]);
//    }
//    return rgb_image;
//}
//
//pixel pixel_hsv_to_rgb(hsv_pixel* hsv)
//{
//    pixel rgb;
//    // h,s,v in [0,1]
//    double h, s, v;
//    h = hsv->hue;
//    s = hsv->sat;
//    v = hsv->val;
//    
//    float rr = 0, gg = 0, bb = 0;
//    float hh = fmod((6 * h),6);                 
//    unsigned char c1 = (unsigned char) hh;                     
//    float c2 = hh - c1;
//    float x = (1 - s) * v;
//    float y = (1 - (s * c2)) * v;
//    float z = (1 - (s * (1 - c2))) * v;	
//    switch (c1) {
//        case 0: rr=v; gg=z; bb=x; break;
//        case 1: rr=y; gg=v; bb=x; break;
//        case 2: rr=x; gg=v; bb=z; break;
//        case 3: rr=x; gg=y; bb=v; break;
//        case 4: rr=z; gg=x; bb=v; break;
//        case 5: rr=v; gg=x; bb=y; break;
//    }
//    
//    short N = 256;
//    rgb.red = (round(rr*N) < N-1) ? round(rr*N) : N-1;
//    rgb.green = (round(gg*N) < N-1) ? round(gg*N) : N-1; 
//    rgb.blue = (round(bb*N) < N-1) ? round(bb*N) : N-1; 
//    
//    return rgb;
//}
//
//pixel* image_copy(pixel* image, int width, int height)
//{
//    int i = 0;
//    int length = width * height;
//    pixel* copy = malloc(length*sizeof(pixel));
//    
//    for(i; i < length; i++)
//    {
//        pixel p = image[i];
//        copy[i] = p;
//    }
//    return copy;
//}
//
//// routine for combining two images
//pixel* image_copyBits(pixel* image1, pixel* image2, int width, int height, int type)
//{
//	int i = 0;
//	int length = width * height;
//	int tempRed, tempGreen, tempBlue;
//    
//	// addition
//	if(type == ADD)
//	{
//		for(i; i < length; i++)
//		{
//			tempRed = image1[i].red + image2[i].red;
//			tempGreen = image1[i].green + image2[i].green;
//			tempBlue = image1[i].blue + image2[i].blue;
//            
//			// clamp values
//			tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//			tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//			tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//            
//			image1[i].red = (unsigned char)tempRed;
//			image1[i].green = (unsigned char)tempGreen;
//			image1[i].blue = (unsigned char)tempBlue;
//		}
//	}
//    
//	// subtraction
//	else if(type == SUB)
//	{
//		for(i; i < length; i++)
//		{
//			tempRed = image1[i].red - image2[i].red;
//			tempGreen = image1[i].green - image2[i].green;
//			tempBlue = image1[i].blue - image2[i].blue;
//            
//			// clamp values
//			tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//			tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//			tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//            
//			image1[i].red = (unsigned char)tempRed;
//			image1[i].green = (unsigned char)tempGreen;
//			image1[i].blue = (unsigned char)tempBlue;
//		}
//	}
//    
//	// TODO - add multiplication and division
//	return image1;
//}
//
//pixel* image_pointOp(pixel* image, float alpha, int width, int height, int type)
//{
//	int i = 0;
//	int length = width * height;
//	int tempRed, tempGreen, tempBlue;
//	int intAlpha = (int)alpha;
//    
//	// if alpha corresponds to an integer value then do int ops to save time
//	if(ceilf(alpha) == alpha)
//	{
//		if(type == ADD)
//		{
//			for(i; i < length; i++)
//			{
//				tempRed = image[i].red + intAlpha;
//				tempGreen = image[i].green + intAlpha;
//				tempBlue = image[i].blue + intAlpha;
//                
//				// clamp values
//				tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//				tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//				tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//                
//				image[i].red = (unsigned char)tempRed;
//				image[i].green = (unsigned char)tempGreen;
//				image[i].blue = (unsigned char)tempBlue;
//			}
//		}
//        
//		else if(type == SUB)
//		{
//			for(i; i < length; i++)
//			{
//				tempRed = image[i].red - intAlpha;
//				tempGreen = image[i].green - intAlpha;
//				tempBlue = image[i].blue - intAlpha;
//                
//				// clamp values
//				tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//				tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//				tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//                
//				image[i].red = (unsigned char)tempRed;
//				image[i].green = (unsigned char)tempGreen;
//				image[i].blue = (unsigned char)tempBlue;
//			}
//		}
//        
//		else if(type == MUL)
//		{
//			for(i; i < length; i++)
//			{
//				tempRed = image[i].red * intAlpha;
//				tempGreen = image[i].green * intAlpha;
//				tempBlue = image[i].blue * intAlpha;
//                
//				// clamp values
//				tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//				tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//				tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//                
//				image[i].red = (unsigned char)tempRed;
//				image[i].green = (unsigned char)tempGreen;
//				image[i].blue = (unsigned char)tempBlue;
//			}
//		}
//        
//		else
//		{
//			for(i; i < length; i++)
//			{
//				tempRed = image[i].red / intAlpha;
//				tempGreen = image[i].green / intAlpha;
//				tempBlue = image[i].blue / intAlpha;
//                
//				// clamp values
//				tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//				tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//				tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//                
//				image[i].red = (unsigned char)tempRed;
//				image[i].green = (unsigned char)tempGreen;
//				image[i].blue = (unsigned char)tempBlue;
//			}
//		}
//	}
//    
//	else
//    {
//        if(type == ADD)
//        {
//            for(i; i < length; i++)
//            {
//                tempRed = image[i].red + alpha;
//                tempGreen = image[i].green + alpha;
//                tempBlue = image[i].blue + alpha;
//                
//                // clamp values
//                tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//                tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//                tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//                
//                image[i].red = (unsigned char)tempRed;
//                image[i].green = (unsigned char)tempGreen;
//                image[i].blue = (unsigned char)tempBlue;
//            }
//        }
//        
//        else if(type == SUB)
//        {
//            for(i; i < length; i++)
//            {
//                tempRed = image[i].red - alpha;
//                tempGreen = image[i].green - alpha;
//                tempBlue = image[i].blue - alpha;
//                
//                // clamp values
//                tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//                tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//                tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//                
//                image[i].red = (unsigned char)tempRed;
//                image[i].green = (unsigned char)tempGreen;
//                image[i].blue = (unsigned char)tempBlue;
//            }
//        }
//        
//        else if(type == MUL)
//        {
//            for(i; i < length; i++)
//            {
//                tempRed = image[i].red * alpha;
//                tempGreen = image[i].green * alpha;
//                tempBlue = image[i].blue * alpha;
//                
//                // clamp values
//                tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//                tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//                tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//                
//                image[i].red = (unsigned char)tempRed;
//                image[i].green = (unsigned char)tempGreen;
//                image[i].blue = (unsigned char)tempBlue;
//            }
//        }
//        
//        else
//        {
//            for(i; i < length; i++)
//            {
//                tempRed = image[i].red / alpha;
//                tempGreen = image[i].green / alpha;
//                tempBlue = image[i].blue / alpha;
//                
//                // clamp values
//                tempRed = tempRed > 255 ? 255 : tempRed < 0 ? 0 : tempRed;
//                tempGreen = tempGreen > 255 ? 255 : tempGreen < 0 ? 0 : tempGreen;
//                tempBlue = tempBlue > 255 ? 255 : tempBlue < 0 ? 0 : tempBlue;
//                
//                image[i].red = (unsigned char)tempRed;
//                image[i].green = (unsigned char)tempGreen;
//                image[i].blue = (unsigned char)tempBlue;
//            }
//        }
//    }
//}
//
//// convert int array back to image after working outside of char bounds
//pixel* intArray_to_image(int* intArray, int width, int height, pixel* image)
//{
//	int i, j;
//	int image_length = (width * height)/3;
//    
//	if(image == NULL)
//		image = malloc(image_length*sizeof(pixel));
//    
//	for(i = 0; i < image_length; i++)
//	{
//		j = i*3;
//		image[i].red = intArray[j] > 255 ? 255 : intArray[j] < 0 ? 0 : intArray[j];
//		image[i].green = intArray[j+1] > 255 ? 255 : intArray[j+1] < 0 ? 0 : intArray[j+1];
//		image[i].blue = intArray[j+2] > 255 ? 255 : intArray[j+2] < 0 ? 0 : intArray[j+2];
//		image[i].alpha = 255;
//	}
//	return image;
//}
//
//// convert an image to an int array in order to work outside of char bounds
//// NOTE: alpha values are not copied; save the original image to pass to reverse conversion
////       function if you want to add in alpha values after conversion using Modify_Alpha
//int* image_to_intArray(pixel* image, int width, int height, int* intArray)
//{
//	int i, j;
//	int array_length = (width * height) * 3;
//	if(intArray == NULL)
//		intArray = malloc(array_length*sizeof(int));
//    
//	for(i = 0; i < width*height; i++)
//	{
//		j = i*3;
//        
//		intArray[j] = image[i].red;
//		intArray[j+1] = image[i].green;
//		intArray[j+2] = image[i].blue;
//	}
//	return intArray;
//}
//
//int* intArray_copyBits(int* intArray1, int* intArray2, int width, int height, int type)
//{
//	int i = 0;
//	int length = width * height;
//    
//	if(type == ADD)
//		for(i; i < length; i++)
//			intArray1[i] += intArray2[i];
//    
//	else if(type == SUB)
//		for(i; i < length; i++)
//			intArray1[i] -= intArray2[i];
//    
//	else if(type == MUL)
//		for(i; i < length; i++)
//			intArray1[i] *= intArray2[i];
//    
//	else
//		for(i; i < length; i++)
//			intArray1[i] /= intArray2[i];
//    
//	return intArray1;
//}
//
//int* intArray_pointOp(int* intArray, float alpha, int width, int height, int type)
//{
//	int i = 0;
//	int length = width * height;
//	int intAlpha = (int)alpha;
//    
//	// if alpha corresponds to an integer value then do int ops to save time
//	if(ceilf(alpha)==alpha)
//	{
//		if(type == ADD)
//			for(i; i < length; i++)
//				intArray[i] += intAlpha;
//		else if(type == SUB)
//			for(i; i < length; i++)
//				intArray[i] -= intAlpha;
//		else if(type == MUL)
//			for(i; i < length; i++)
//				intArray[i] *= intAlpha;
//		else
//			for(i; i < length; i++)
//				intArray[i] /= intAlpha;
//	}
//    
//	// if alpha corresponds to an integer value then do int ops to save time
//	else
//	{
//		if(type == ADD)
//			for(i; i < length; i++)
//				intArray[i] += alpha;
//		else if(type == SUB)
//			for(i; i < length; i++)
//				intArray[i] -= alpha;
//		else if(type == MUL)
//			for(i; i < length; i++)
//				intArray[i] *= alpha;
//		else
//			for(i; i < length; i++)
//				intArray[i] /= alpha;
//	}
//	return intArray;
//}
//
//// spatial filter methods
//// the kernel must be freed by calling function 
//kernel_1d Make_Gaussian_1d_Kernel(double sigma)
//{
//    int i = 0;
//    kernel_1d newKernel;
//    
//    // create the kernel
//    int center = (int) (3.0*sigma);
//    int length = 2*center+1;
//    
//    double* kernel_d = malloc(length*sizeof(double));
//    int* kernel_i = malloc(length*sizeof(int));
//    
//    // fill the double kernel
//    double sigma2 = sigma * sigma;
//    for (i; i < length; i++){
//        double r = center - i;
//        kernel_d[i] = (double)exp(-0.5 * (r*r) / sigma2);
//    }
//    
//    // fill the int kernel
//    // find min value
//    double min;
//    min = kernel_d[0];
//    for(i = 1; i < length; i++)
//        if(kernel_d[i] < min) min = kernel_d[i];
//    
//    double coeff = 1.0/min;
//    int sum = 0;
//    for(i = 0; i < length; i++)
//    {
//        kernel_i[i] = (int)(kernel_d[i] * coeff);
//        sum += kernel_i[i];
//    }
//    
//    newKernel.kernel_int = kernel_i;
//    newKernel.kernel_double = kernel_d;
//    newKernel.sum = sum;
//    newKernel.length = length;
//    
//    return newKernel;
//}
//
//pixel* Gaussian_Blur(pixel* image, double sigma, int width, int height, int type)
//{
//	// compute the kernel
//	kernel_1d kernel = Make_Gaussian_1d_Kernel(sigma);
//    
//	// if float computation then normalize kernel
//	if(type == FLOAT)
//	{
//		double sum = 0;
//		int i = 0;
//		for(i; i < kernel.length; i++)
//		{
//			sum += kernel.kernel_double[i];
//		}
//		for(i = 0; i < kernel.length; i++)
//		{
//			kernel.kernel_double[i] = kernel.kernel_double[i]/sum;
//		}
//	}
//    
//	// convolve
//	ConvolveInX(image, kernel, width, height, type);
//	ConvolveInY(image, kernel, width, height, type);
//    
//	// free the kernel pointers
//	free(kernel.kernel_double);
//	free(kernel.kernel_int);
//    
//	return image;
//}
//
//pixel* Blur_Or_Sharpen(pixel* image, double sigma, float w, int width, int height, int type)
//{
//	// w must be between -1 and 1
//	if(w < -1 || w > 1)
//		return NULL;
//    
//	// compute the kernel
//	kernel_1d kernel = Make_Gaussian_1d_Kernel(sigma);
//    
//	// if float computation then normalize kernel
//	if(type == FLOAT)
//	{
//		double sum = 0;
//		int i = 0;
//		for(i; i < kernel.length; i++)
//		{
//			sum += kernel.kernel_double[i];
//		}
//		for(i = 0; i < kernel.length; i++)
//		{
//			kernel.kernel_double[i] = kernel.kernel_double[i]/sum;
//		}
//	}
//    
//	// build intArray from image so we can work outside char bounds
//	int* intArray1 = image_to_intArray(image, width, height, NULL);
//	intArray_pointOp(intArray1, 1+w, width*3, height, 2);
//    
//	// convolve
//	ConvolveInX(image, kernel, width, height, type);
//	ConvolveInY(image, kernel, width, height, type);
//    
//	// build intArray from image so we can work outside char bounds
//	int* intArray2 = image_to_intArray(image, width, height, NULL);
//	intArray_pointOp(intArray2, w, width*3, height, 2);
//    
//	intArray_copyBits(intArray1, intArray2, width*3, height, 1);
//    
//	intArray_to_image(intArray1, width*3, height, image);
//    
//	// free the kernel pointers, int arrays
//	free(kernel.kernel_double);
//	free(kernel.kernel_int);
//	free(intArray1);
//	free(intArray2);
//    
//	return image;
//}
//
//
//// convolution methods
//pixel* ConvolveInX(pixel* image, kernel_1d kernel, int width, int height, int type)
//{
//    // need to make duplicate image
//    pixel* copy = image_copy(image, width, height);
//    
//    int r = kernel.length/2;
//    int w = width - 2 * r;
//    int i, j, k;
//    
//    // use float convolution for precise, non real-time processing
//    if(type == FLOAT)
//    {
//        double rsum, gsum, bsum, red, green, blue;
//        
//        for(j = 0; j < height; j++)
//        {
//            for(i = -r; i < width-r; i++)
//            {
//                int l = ((i + w) % w);
//                rsum = 0;
//                gsum = 0;
//                bsum = 0;
//                for(k = -r; k <= r; k++)
//                {
//                    pixel p = *(copy+(j*width)+l+k+r);
//                    red = p.red;
//                    green = p.green;
//                    blue = p.blue;
//                    
//                    // double p = copy.getf(l+k+r,j);
//                    rsum += red * kernel.kernel_double[k+r];
//                    gsum += green * kernel.kernel_double[k+r];
//                    bsum += blue * kernel.kernel_double[k+r];
//                }
//                // !! finish proper pointer computation here
//                pixel p;
//                
//                // clamp values
//                rsum = rsum > 255 ? 255 : rsum < 0 ? 0 : rsum;
//                gsum = gsum > 255 ? 255 : gsum < 0 ? 0 : gsum;
//                bsum = bsum > 255 ? 255 : bsum < 0 ? 0 : bsum;
//                
//                // round floats
//                p.red = (unsigned char)rsum;
//                p.green = (unsigned char)gsum;
//                p.blue = (unsigned char)bsum;
//                
//                *(image+(j*width)+(i+r)) = p;
//            }
//        }
//    }
//    
//    // use int convolution for faster results but some slight data loss
//    else
//    {
//        int rsum, gsum, bsum, red, green, blue;
//        
//        for(j = 0; j < height; j++)
//        {
//            for(i = -r; i < width-r; i++)
//            {
//                int l = ((i + w) % w);
//                rsum = 0;
//                gsum = 0;
//                bsum = 0;
//                for(k = -r; k <= r; k++)
//                {
//                    pixel p = *(copy+(j*width)+l+k+r);
//                    red = (int)p.red;
//                    green = (int)p.green;
//                    blue = (int)p.blue;
//                    
//                    rsum += red * kernel.kernel_int[k+r];
//                    gsum += green * kernel.kernel_int[k+r];
//                    bsum += blue * kernel.kernel_int[k+r];
//                }
//                
//                // normalize values
//                float redf, greenf, bluef;
//                redf = ((float)rsum)/kernel.sum;
//                greenf = ((float)gsum)/kernel.sum;
//                bluef = ((float)bsum)/kernel.sum;
//                
//                // clamp values
//                redf = redf > 255 ? 255 : redf < 0 ? 0 : redf;
//                greenf = greenf > 255 ? 255 : greenf < 0 ? 0 : greenf;
//                bluef = bluef > 255 ? 255 : bluef < 0 ? 0 : bluef;
//                
//                // round floats
//                pixel p;
//                p.red = (unsigned char)redf;
//                p.green = (unsigned char)greenf;
//                p.blue = (unsigned char)bluef;
//                
//                *(image+(j*width)+(i+r)) = p;
//            }
//        }
//    }
//    free(copy);
//}
//
//pixel* ConvolveInY(pixel* image, kernel_1d kernel, int width, int height, int type)
//{
//    // need to make duplicate image
//    pixel* copy = image_copy(image, width, height);
//    
//    int r = kernel.length/2;
//    int w = height - 2 * r;
//    int i, j, k;
//    
//    if(type == FLOAT)
//    {
//        double rsum, gsum, bsum, red, green, blue;
//        
//        for(i = 0; i < width; i++)
//        {
//            for(j = -r; j < height-r; j++)
//            {
//                int l = ((j + w) % w);
//                rsum = 0.0;
//                gsum = 0.0;
//                bsum = 0.0;
//                for(k = -r; k <= r; k++)
//                {
//                    pixel p = *(copy+i+(width*(l+k+r)));
//                    red = p.red;
//                    green = p.green;
//                    blue = p.blue;
//                    
//                    // double p = copy.getf(l+k+r,j);
//                    rsum += red * kernel.kernel_double[k+r];
//                    gsum += green * kernel.kernel_double[k+r];
//                    bsum += blue * kernel.kernel_double[k+r];
//                }
//                pixel p;
//                
//                // clamp values
//                rsum = rsum > 255 ? 255 : rsum < 0 ? 0 : rsum;
//                gsum = gsum > 255 ? 255 : gsum < 0 ? 0 : gsum;
//                bsum = bsum > 255 ? 255 : bsum < 0 ? 0 : bsum;
//                
//                // round floats
//                p.red = (unsigned char)rsum;
//                p.green = (unsigned char)gsum;
//                p.blue = (unsigned char)bsum;
//                
//                *(image+(width*(j+r)+i)) = p;
//            }
//        }
//    }
//    
//    else
//    {
//        int rsum, gsum, bsum, red, green, blue;
//        
//        for(i = 0; i < width; i++)
//        {
//            for(j = -r; j < height-r; j++)
//            {
//                int l = ((j + w) % w);
//                rsum = 0.0;
//                gsum = 0.0;
//                bsum = 0.0;
//                for(k = -r; k <= r; k++)
//                {
//                    pixel p = *(copy+i+(width*(l+k+r)));
//                    red = p.red;
//                    green = p.green;
//                    blue = p.blue;
//                    
//                    // double p = copy.getf(l+k+r,j);
//                    rsum += red * kernel.kernel_int[k+r];
//                    gsum += green * kernel.kernel_int[k+r];
//                    bsum += blue * kernel.kernel_int[k+r];
//                }
//                // normalize values
//                float redf, greenf, bluef;
//                redf = ((float)rsum)/kernel.sum;
//                greenf = ((float)gsum)/kernel.sum;
//                bluef = ((float)bsum)/kernel.sum;
//                
//                // clamp values
//                redf = redf > 255 ? 255 : redf < 0 ? 0 : redf;
//                greenf = greenf > 255 ? 255 : greenf < 0 ? 0 : greenf;
//                bluef = bluef > 255 ? 255 : bluef < 0 ? 0 : bluef;
//                
//                // round floats
//                pixel p;
//                p.red = (unsigned char)redf;
//                p.green = (unsigned char)greenf;
//                p.blue = (unsigned char)bluef;
//                
//                *(image+(width*(j+r)+i)) = p;
//            }
//        }
//    }
//    free(copy);
//}
