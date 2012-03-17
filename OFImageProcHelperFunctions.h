//
//  OFImageProcHelperFunctions.h
//  ImgProc
//
//  Created by Jamis Johnson on 2/27/12.
//  Copyright (c) 2012 University of Utah. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OFImageProcHelperFunctions : NSObject
{
    
}

+ (unsigned char *) convertUIImageToByteArray:(UIImage*)image;
+ (UIImage *) grayscaleImage:(UIImage*)image;

@end
