#ifndef ADD_H_GUARD
#define ADD_H_GUARD

typedef struct pixel{
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char alpha;
} pixel;

typedef struct hsv_pixel{
    double hue;
    double sat;
    double val;
} hsv_pixel;

typedef struct kernel_1d{
    int* kernel_int;
    double* kernel_double;
    int length;
    int sum;
} kernel_1d;

// add 2d kernel later for morphological operators
/*
 typedef struct kernel_2d{
 unsigned char* kernel;
 unsigned int width;
 unsigned int height;
 unsigned int sum;
 }
 */

// point operations - grayscale
unsigned char* Invert_Pixels_Gray(unsigned char* image, int width, int height);
//unsigned char* Modify_Contrast_Gray(unsigned char* image, int alpha, int width, int height);
//unsigned char* Modify_Brightness_Gray(unsigned char* image, int alpha, int width, int height);
//unsigned char* Threshold_Gray(unsigned char* image, int alpha, int width, int height);
//unsigned char* Gamma_Corr_Gray(unsigned char* image, double alpha,  int width, int height);
//
//// all point operations have been successfully tested in android except Modify_Alpha
//// need a background image to display transparency in order to test Modify_Alpha 
//
//// point operations - rgba - destructive
pixel* Invert_Pixels_D(pixel* image, int width, int height);
pixel* Modify_Contrast_D(pixel* image, int alpha, int width, int height);
pixel* Modify_Brightness_D(pixel* image, int alpha, int width, int height);
pixel* Threshold_D(pixel* image, int alpha, int width, int height);
pixel* Gamma_Corr_D(pixel* image, double alpha, int width, int height);
//pixel* Modify_Alpha_D(pixel* image, int alpha, int width, int height);
//
//// point operations - rgba - non-destructive
//// these are for slider bar type operations in GUIs
//pixel* Modify_Contrast_ND(pixel* image, int alpha, int width, int height, pixel* output);
//pixel* Modify_Brightness_ND(pixel* image, int alpha, int width, int height, pixel* output);
//pixel* Threshold_ND(pixel* image, int alpha, int width, int height, pixel* output);
//pixel* Gamma_Corr_ND(pixel* image, double alpha, int width, int height, pixel* output);
//pixel* Modify_Alpha_ND(pixel* image, int alpha, int width, int height, pixel* output);
//
///*
// // Auto_Contrast: only for gray?
// // Histogram equilization will be different for gray vs color
// // RGB hist_eq will require conversion to HSV, eq of value channel, conversion back to RGB
// pixel* Auto_Contrast(pixel* image, int width, int height);
// pixel* Histogram_Eq_Gray(pixel* image, int width, int height);
// pixel* Histogram_Eq_Color(pixel* image, int width, int height);
// */
//
//// analysis
//// These methods have not been tested
//unsigned long* Histogram_Lum(pixel* image, int width, int height, unsigned long* histogram);
//unsigned long** Histogram_Color(pixel* image, int width, int height, unsigned long** histogram);
//unsigned long* Cum_Histogram_Lum(pixel* image, int width, int height, unsigned long* histogram);
//unsigned long** Cum_Histogram_Color(pixel* image, int width, int height, unsigned long** histogram);
//
//// utility methods - conversion
//// RGB to grayscale conversion routines
//unsigned char* RGB_to_Gray_CharArray(pixel* image, int width, int height, unsigned char* gray_Image);
//pixel* RGB_to_Gray_PixelArray(pixel* image, int width, int height);
//
//// RGB-HSV conversion routines
//// These methods appear to convert back and forth with no loss; need more testing?
//// Any other cool way to use this?
//hsv_pixel* image_rgb_to_hsv(pixel* rgb_image, int width, int height, hsv_pixel* hsv_image);
//hsv_pixel pixel_rgb_to_hsv(pixel* rgb);
//pixel* image_hsv_to_rgb(hsv_pixel* hsv_image, int width, int height, pixel* rgb_image);
//pixel pixel_hsv_to_rgb(hsv_pixel* hsv);
//
//// utility methods - type conversion, image combination, point operations
//// caller must free memory for new copy of image
//pixel* image_copy(pixel* image, int width, int height);
//pixel* image_copyBits(pixel* image1, pixel* image2, int width, int height, int type);
//pixel* image_pointOp(pixel* image, float alpha, int width, int height, int type);
//pixel* intArray_to_image(int* intArray, int width, int height, pixel* image);
//int* image_to_intArray(pixel* image, int width, int height, int* intArray);
//int* intArray_copyBits(int* intArray1, int* intArray2, int width, int height, int type);
//int* intArray_pointOp(int* intArray, float alpha, int width, int height, int type);
//
//// spatial filter methods
//kernel_1d Make_Gaussian_1d_Kernel(double sigma);
//pixel* Gaussian_Blur(pixel* image, double sigma, int width, int height, int type);
//pixel* Blur_Or_Sharpen(pixel* image, double sigma, float w, int width, int height, int type);
//
//// convolution methods
//pixel* ConvolveInX(pixel* image, kernel_1d kernel, int width, int height, int type);
//pixel* ConvolveInY(pixel* image, kernel_1d kernel, int width, int height, int type);
//
///* 
// // edge detection
// gradient magnitude routine 
// sobel edge detection
// prewitt edge detection
// 
// // morphological filters
// erode
// dilate
// open
// close
// outline
// skeletonize
// */
//
#endif
