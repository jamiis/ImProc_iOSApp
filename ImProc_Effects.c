// ImProc_Effects.c
// Image Processing Library
// Naming Semantics - All methods called from outside the library have leading capital letters
//                    All utility methods called from within the library have leading lowercase letters
//                    Utility methods should generally not be called from outside the library unless the
//                    implementer understands the function usage and memory allocations involved

#include <math.h>
#include <stdlib.h>
#include "ImProc_Effects.h"
#include "ImProc_Utils.h"
#include "ImProc_Edges.h"
#include "ImProc_Filters.h"

pixel* Cartoon(pixel* image, int lines, int colors, int width, int height, pixel* output)
{
	int i, length;
	length = width * height;
	pixel* copy = pixel_copy(image, width, height);
	Sobel_Edges(image, 0, 0, width, height, output);

	// custom threshold for multiplication
	for(i = 0; i < length; i++)
	{
		pixel oldPixel = output[i];
		if(oldPixel.red > lines)
			oldPixel.red = oldPixel.blue = oldPixel.green = 0;
		else
			oldPixel.red = oldPixel.blue = oldPixel.green = 1;
		output[i] = oldPixel;
	}

	Posterize(copy, colors, width, height, copy);

	for(i = 0; i < length;  i++)
	{
		pixel outputPixel = output[i];
		pixel copyPixel = copy[i];
		outputPixel.red *= copyPixel.red;
		outputPixel.blue *= copyPixel.blue;
		outputPixel.green *= copyPixel.green;
		output[i] = outputPixel;
	}

	free(copy);
	return output;
}

pixel* Posterize(pixel* image, int levels, int width, int height, pixel* output)
{
	int i;
	int length = width * height;
	int colorLevels[256];
	if (levels != 1)
		for (i = 0; i < 256; i++)
			colorLevels[i] = 255 * (levels*i / 256) / (levels-1);

	for(i = 0;  i < length; i++)
	{
		pixel newPixel = image[i];
		newPixel.red = colorLevels[newPixel.red];
		newPixel.blue = colorLevels[newPixel.blue];
		newPixel.green = colorLevels[newPixel.green];

		output[i] = newPixel;
	}

	return output;
}
