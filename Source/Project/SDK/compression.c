#include <stdio.h>
#include "xil_printf.h"
#include "xil_types.h"
#include "compression.h"
#include "camera_picture.h"
#include "cmpr_picture.h"
#include <math.h>

/*~~~~~~~~~~FIXED POINT~~~~~~~~~~*/
typedef int Fixed;

#define FRACT_BITS 11
#define FRACT_BITS_D2 8
#define FIXED_ONE (1 << FRACT_BITS)
#define INT2FIXED(x) ((x) << FRACT_BITS)
#define FLOAT2FIXED(x) ((int)((x) * (1 << FRACT_BITS)))
#define FIXED2INT(x) ((x) >> FRACT_BITS)
#define FIXED2DOUBLE(x) (((double)(x)) / (1 << FRACT_BITS))
#define MULT(x, y) ( ((x) >> FRACT_BITS_D2) * ((y)>> FRACT_BITS_D2) )
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

//Debug printing
#if(0)
	#define DPRINT(args...) printf(args)
#else
	#define DPRINT(args...)
#endif

u32 WIDTH;
u32 HEIGHT;

u32 *PIC_BASE_ADDR = cam_pic;

/* IMAGE COMPRESSION */
//width 		- width of original photo
//height 		- height of original photo
//cmpr_width 	- wanted width of photo after compression
//cmpr_height 	- wanted height of photo after compression
//cmpr_factor	- compression factor [Amount of bits compressed into one bit - in other words, scaling] - 4 in our case
void img_cmpr(int width,int height,int cmpr_width,int cmpr_height,int cmpr_factor)
{
	WIDTH 	= (u32)width;
	HEIGHT 	= (u32)height;
	int x_margin = ((width-cmpr_width)/2);
	int y_margin = ((height-cmpr_height)/2);
	u16 cmpr_pic_cnt = 0;

	for(int p=0;p<(160*120);p++)
	{
		cam_pic[p] = (u32)( (((float)((cam_pic[p] & 0x00FF0000) >> 16)) *0.114)  + (((float)((cam_pic[p] & 0x0000FF00) >> 8)) *0.587) + ((float)(cam_pic[p] & 0x000000FF)*0.299));

		//Changing threshold value
		if(((int)cam_pic[p]) > 100)
			cam_pic[p] = 0x000000FF;
		else
			cam_pic[p] = 0x00000000;

		DPRINT("%d\n",(int)cam_pic[p]);
	}



	for(int y=0;y<height;y+=cmpr_factor)
	{
		for(int x=0;x<width;x+=cmpr_factor)
		{
			//If we are in compressed area
			if( (x >= x_margin) & (x < width-x_margin) & (y >= y_margin) & (y < height-y_margin) )
			{
				cmpr_pic[cmpr_pic_cnt] = scale_pixels(x,y,cmpr_factor);
				cmpr_pic_cnt++;
				DPRINT("X = %d || Y = %d - Inside\n",x+1,y+1);
			}else
				DPRINT("X = %d || Y = %d\n",x+1,y+1);
		}
	}

	//Changing threshold value ONE MORE TIME
	for(int p=0;p<784;p++)
	{
		if(((int)cmpr_pic[p]) > 250)
			cmpr_pic[p] = 0x000000FF;
		else
			//cmpr_pic[p] = cmpr_pic[p] - 0x0000003F;
			cmpr_pic[p] = 0x00000000;
	}

	//ZA MATLAB
	//for(int z=0;z<784;z++)
		//printf("%d\n",(int)cmpr_pic[z]);

	//ZA NCSIM
	/*for(int z=0;z<784;z++)
	W{
		if( ((int)cmpr_pic[z]) == 255)
			printf("16'b0000000000000000,\n");
		else
			printf("16'b0000100000000000,\n");

	}*/

	//ZA POPA
	//for(int z=0;z<784;z++)
		//printf("%f\n",((float)(255 - cmpr_pic[z]) / 255.0));

	//Inverting values(Values X rotation around number 127), scaling it from 255-0 to 1-0 and turning it to fixed point system Sign.4.11

	for(int k=0;k<784;k++)
	{
		//cmpr_pic[k] = FLOAT2FIXED(  ((float)(255 - cmpr_pic[k]) / 255.0)  );
		//cmpr_pic[k] = ( ( (cmpr_pic[k] & 0x0000FFFF) << 16 ) | (cmpr_pic[k] & 0x0000FFFF) );
		if(cmpr_pic[k] == 255)
			cmpr_pic[k] = 0x00000000;
		else
			cmpr_pic[k] = 0x08000800;
	}
	for(int z=0;z<784;z++)
		printf("%08X\n",(int)cmpr_pic[z]);
}

u32 scale_pixels(int x, int y, int cmpr_factor)
{
	u32   pixel_val_gray   = 0;
	float pixel_val_gray_f = 0;
	u32   pixel_val     = 0;
	u32   z 			= 0; // this is same as cmpr_factor^2

	for(int j=0;j<cmpr_factor;j++)
		for(int i=0;i<cmpr_factor;i++)
		{
			pixel_val_gray = pixel_val_gray + cam_pic[(x+i)+((y+j)*WIDTH)];
			z++;
		}

	pixel_val_gray_f = ((float)pixel_val_gray/(float)z);


	pixel_val = (u32)pixel_val_gray_f;

	return pixel_val;
}

u32 rgb_add_r(u32 M, u32 N)
{
	u32 M_r = M;
	u32 N_r = 0;

	N_r =  N & 0x000000FF;
	M_r += N_r;
	return M_r;
}

u32 rgb_add_g(u32 M, u32 N)
{
	u32 M_g = M;
	u32 N_g = 0;

	N_g = (N & 0x0000FF00) >> 8 ;
	M_g += N_g;
	return M_g;
}

u32 rgb_add_b(u32 M, u32 N)
{
	u32 M_b = M;
	u32 N_b = 0;

	N_b = (N & 0x00FF0000) >> 16;
	M_b += N_b;
	return M_b;
}

