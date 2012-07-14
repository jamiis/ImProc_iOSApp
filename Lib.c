#include <pthread.h>
#include <string.h>
#include <jni.h>
#include <android/log.h>
#include <android/bitmap.h>
#include <stdlib.h>
#include "ImProc_Base.h"
#include "ImProc_Edges.h"
#include "ImProc_Filters.h"
#include "ImProc_Histogram.h"
#include "ImProc_Effects.h"
#include "ImProc_Utils.h"
#include "ImProc_Color.h"

//#define getGray(color) (0.3f * color.red + 0.59f*color.green + 0.11f*color.blue)
unsigned char getGray(pixel color) {
  short temp = color.red;
  temp += color.green + color.blue;
  temp /= 3;
  return (unsigned char)temp;
}

pixel getColored(unsigned char gray) {
  pixel pix;
  pix.red = pix.green = pix.blue = gray;
  return pix;
}

int getWidth(JNIEnv *env, jobject bitmap) {
  AndroidBitmapInfo info;
  AndroidBitmap_getInfo(env, bitmap, &info);
  return info.width;
}

int getHeight(JNIEnv *env, jobject bitmap) {
  AndroidBitmapInfo info;
  AndroidBitmap_getInfo(env, bitmap, &info);
  return info.height;
}

pixel *getPixels(JNIEnv *env, jobject bitmap) {
  void *pixelsP;
  AndroidBitmap_lockPixels(env, bitmap, &pixelsP);
  return (pixel *)pixelsP;
}

void freePixels(JNIEnv *env, jobject bitmap) {
  AndroidBitmap_unlockPixels(env, bitmap);
}

jint Java_com_overfitters_Native_Compress(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int widthI, heightI, widthM, heightM;
  
  widthI = getWidth(env, imu);
  heightI = getHeight(env, imu);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  int scale = widthI/widthM;
  if(heightI/heightM != scale)
    return -1;

  int eX,eY;
  eX = widthI%scale;
  eY = heightI%scale;

  eX/=2;
  eY/=2;

  //TODO, make a library call instead
  int i,j;
  for(i = 0; i<widthM; i++) {
    for(j = 0; j<heightM; j++) {
      int red, green, blue;
      red = green = blue = 0;
      int m,n;
      for(m = 0; m<scale; m++) {
	for(n = 0; n<scale; n++) {
	  int index = (scale*i+m+eX)+(scale*j+n+eY)*widthI;
	  red += pixelsI[index].red;
	  green += pixelsI[index].green;
	  blue += pixelsI[index].blue;
	}
      }
      red /= (scale*scale);
      green /= (scale*scale);
      blue /= (scale*scale);
      pixelsM[i+j*widthM].red = red;
      pixelsM[i+j*widthM].green = green;
      pixelsM[i+j*widthM].blue = blue;
      pixelsM[i+j*widthM].alpha = 0xff;
    }
  }

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_Copy(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int width, height;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
  
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  //TODO, make a library call instead
  pixel pix;
  int i,j;
  for(i = 0; i<width; i++) {
    for(j = 0; j<height; j++) {
      pixelsM[i+j*width] = pixelsI[i+j*width];
      pixelsM[i+j*width].alpha = 0xff;
    }
  }

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_ColorToGray(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int width, height, widthM, heightM;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  RGB_to_Gray_PixelArray(pixelsI, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_GetBrightness(JNIEnv *env, jobject thiz, jobject mut) {
  pixel *pixels;
  int width, height;
  
  width = getWidth(env, mut);
  height = getHeight(env, mut);
    
  pixels = getPixels(env, mut);

  //TODO, make a library call instead
  long sum = 0;
  int i,j;
  for(i = 0; i<width; i++) {
    for(j = 0; j<height; j++) {
      sum+= getGray(pixels[i+j*width]);
    }
  }

  sum/=width*height;

  freePixels(env, mut);

  return sum;
}

jint Java_com_overfitters_Native_InvertColored(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int width, height, widthM, heightM;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

	widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Invert_Pixels(pixelsI, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_InvertGray(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int width, height, widthM, heightM;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Invert_Pixels(pixelsI, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_ModBrightness(JNIEnv *env, jobject thiz, jobject imu, jobject mut, jint alpha) {
  pixel *pixelsI, *pixelsM;
 	int width, height, widthM, heightM;
  int change = (int)alpha;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Modify_Brightness(pixelsI, change, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

//not done
jint Java_com_overfitters_Native_ModContrast(JNIEnv *env, jobject thiz, jobject imu, jobject mut, jfloat alpha) {
  pixel *pixelsI, *pixelsM;
 int width, height, widthM, heightM;
  
  int change = (int)alpha;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  if(imu != mut)
    pixelsM = getPixels(env, mut);
  else
    pixelsM = pixelsI;

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Modify_Contrast(pixelsI, widthM, heightM, change, pixelsM);

  freePixels(env, imu);
  if(imu != mut)
    freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_Gamma(JNIEnv *env, jobject thiz, jobject imu, jobject mut, jdouble alpha) {
  pixel *pixelsI, *pixelsM;
 	int width, height, widthM, heightM;
  double change = alpha;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Gamma_Corr(pixelsI, change, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_BlurOrSharpen(JNIEnv *env, jobject thiz, jobject imu, jobject mut, jfloat alpha) {
  pixel *pixelsI, *pixelsM;
  int width, height, widthM, heightM;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Blur_Or_Sharpen(pixelsI, alpha, widthM, heightM, 1, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_Threshold(JNIEnv *env, jobject thiz, jobject imu, jobject mut, jint alpha) {
  pixel *pixelsI, *pixelsM;
 	int width, height, widthM, heightM;
  int change = (int)alpha;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Threshold(pixelsI, change, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_ModAlpha(JNIEnv *env, jobject thiz, jobject imu, jobject mut, jint alpha) {
  pixel *pixelsI, *pixelsM;
 	int width, height, widthM, heightM;
  int change = (int)alpha;
  
  width = getWidth(env, imu);
  height = getHeight(env, imu);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Modify_Alpha(pixelsI, change, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_GradientMag(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int widthI, heightI, widthM, heightM;
  
  widthI = getWidth(env, imu);
  heightI = getHeight(env, imu);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  int scale = widthI/widthM;
  if(heightI/heightM != scale)
    return -1;
    
  Gradient_Magnitude(pixelsI, 2.0, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_GaussianBlur(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int widthI, heightI, widthM, heightM;
  
  widthI = getWidth(env, imu);
  heightI = getHeight(env, imu);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  int scale = widthI/widthM;
  if(heightI/heightM != scale)
    return -1;
    
  Gaussian_Blur(pixelsI, 4.0, widthM, heightM, 1, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_UnsharpMask(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int widthI, heightI, widthM, heightM;
  
  widthI = getWidth(env, imu);
  heightI = getHeight(env, imu);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  int scale = widthI/widthM;
  if(heightI/heightM != scale)
    return -1;
    
  Unsharp_Masking(pixelsI, 4.0, 1, widthM, heightM, 1, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_FastEdges(JNIEnv *env, jobject thiz, jobject imu, jobject mut, jint alpha) {
  pixel *pixelsI, *pixelsM;
  int width, height, widthM, heightM;
  int change = (int)alpha;

  width = getWidth(env, imu);
  height = getHeight(env, imu);

  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  Cartoon(pixelsI, change, 8, widthM, heightM, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_Custom(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int widthI, heightI, widthM, heightM;
  
  widthI = getWidth(env, imu);
  heightI = getHeight(env, imu);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);
    
  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  Rotate(pixelsI, 90, widthI, heightI, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}

jint Java_com_overfitters_Native_Rotate(JNIEnv *env, jobject thiz, jobject imu, jobject mut) {
  pixel *pixelsI, *pixelsM;
  int widthI, heightI, widthM, heightM;

  widthI = getWidth(env, imu);
  heightI = getHeight(env, imu);

  widthM = getWidth(env, mut);
  heightM = getHeight(env, mut);

  pixelsI = getPixels(env, imu);
  pixelsM = getPixels(env, mut);

  Rotate(pixelsI, 90, widthI, heightI, pixelsM);

  freePixels(env, imu);
  freePixels(env, mut);

  return 0;
}
