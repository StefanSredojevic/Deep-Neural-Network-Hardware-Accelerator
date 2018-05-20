#ifndef __MNIST_H__
#define __MNIST_H__

/*
 * MNIST loader by Nuri Park - https://github.com/projectgalateia/mnist
 */

#ifdef USE_MNIST_LOADER /* Fundamental macro to make the code active */

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Make mnist_load function static.
 * Define when the header is included multiple time.
 */
#ifdef MNIST_STATIC
#define _STATIC static
#else
#define _STATIC 
#endif

/*
 * Make mnist loader to load image data as double type.
 * It divides unsigned char values by 255.0, so the results ranges from 0.0 to 1.0
 */
#ifdef MNIST_DOUBLE
#define MNIST_DATA_TYPE double
#else
#define MNIST_DATA_TYPE unsigned char
#endif

typedef struct mnist_data {
	MNIST_DATA_TYPE data[28][28]; /* 28x28 data for the image */
	unsigned int label; /* label : 0 to 9 */
} mnist_data;

/*
 * If it's header inclusion, make only function prototype visible.
 */
#ifdef MNIST_HDR_ONLY

_STATIC int mnist_load(
	const char *image_filename,
	const char *label_filename,
	mnist_data **data,
	unsigned int *count);

#else

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * Load a unsigned int from raw data.
 * MSB first.
 */
static unsigned int mnist_bin_to_int(char *v)
{
	int i;
	unsigned int ret = 0;

	for (i = 0; i < 4; ++i) {
		ret <<= 8;
		ret |= (unsigned char)v[i];
	}

	return ret;
}

/*
 * MNIST dataset loader.
 *
 * Returns 0 if successed.
 * Check comments for the return codes.
 */
_STATIC int mnist_load(
	const char *image_filename,
	const char *label_filename,
	mnist_data **data,
	unsigned int *count)
{
	int return_code = 0;
	int i;
	char tmp[4];

	unsigned int image_cnt, label_cnt;
	unsigned int image_dim[2];

	FILE *ifp = fopen(image_filename, "rb");
	FILE *lfp = fopen(label_filename, "rb");

	if (!ifp || !lfp) {
		return_code = -1; /* No such files */
		goto cleanup;
	}

	fread(tmp, 1, 4, ifp);
	if (mnist_bin_to_int(tmp) != 2051) {
		return_code = -2; /* Not a valid image file */
		goto cleanup;
	}

	fread(tmp, 1, 4, lfp);
	if (mnist_bin_to_int(tmp) != 2049) {
		return_code = -3; /* Not a valid label file */
		goto cleanup;
	}

	fread(tmp, 1, 4, ifp);
	image_cnt = mnist_bin_to_int(tmp);

	fread(tmp, 1, 4, lfp);
	label_cnt = mnist_bin_to_int(tmp);

	if (image_cnt != label_cnt) {
		return_code = -4; /* Element counts of 2 files mismatch */
		goto cleanup;
	}

	for (i = 0; i < 2; ++i) {
		fread(tmp, 1, 4, ifp);
		image_dim[i] = mnist_bin_to_int(tmp);
	}

	if (image_dim[0] != 28 || image_dim[1] != 28) {
		return_code = -2; /* Not a valid image file */
		goto cleanup;
	}

	*count = image_cnt;
	*data = (mnist_data *)malloc(sizeof(mnist_data) * image_cnt);

	for (i = 0; i < image_cnt; ++i) {
		int j;
		unsigned char read_data[28 * 28];
		mnist_data *d = &(*data)[i];

		fread(read_data, 1, 28*28, ifp);

#ifdef MNIST_DOUBLE
		for (j = 0; j < 28*28; ++j) {
			d->data[j/28][j%28] = read_data[j] / 255.0;
		}
#else
		memcpy(d->data, read_data, 28*28);
#endif

		fread(tmp, 1, 1, lfp);
		d->label = tmp[0];
	}

cleanup:
	if (ifp) fclose(ifp);
	if (lfp) fclose(lfp);

	return return_code;
}

#endif /* MNIST_HDR_ONLY */

#ifdef __cplusplus
}
#endif

#endif /* USE_MNIST_LOADER */
#endif /* __MNIST_H__ */
