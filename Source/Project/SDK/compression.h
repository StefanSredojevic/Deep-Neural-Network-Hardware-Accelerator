/*
 * compression.h
 *
 *  Created on: Apr 24, 2018
 *      Author: Stefan
 */

#ifndef SRC_COMPRESSION_H_
#define SRC_COMPRESSION_H_

void img_cmpr(int width,int height,int cmpr_width,int cmpr_height,int cmpr_factor);
u32 get_pixel_val(u32 x,u32 y);
u32 get_pixel_addr(u32 x,u32 y);
u32 scale_pixels(int x, int y, int cmpr_factor);
u32 grayscale(u32 pixel_val);
u32 rgb_add(u32 M, u32 N);
u32 rgb_add_r(u32 M, u32 N);
u32 rgb_add_g(u32 M, u32 N);
u32 rgb_add_b(u32 M, u32 N);
u32 rgb_devide(u32 R,u32 G,u32 B,u32 devider);

#endif /* SRC_COMPRESSION_H_ */
