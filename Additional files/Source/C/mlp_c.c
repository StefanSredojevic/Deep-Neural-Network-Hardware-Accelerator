#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <ctype.h>

#define USE_MNIST_LOADER
#define MNIST_DOUBLE
#include "mnist.h"

int checker(int, double*);

int main()
{
	int i, f, s, o;
	
	i = 784; 			//number of neurons in input layer 
	f = 16;	 			//number of neurons in first hidden layer
	s = 16;  			//number of neurons in second hidden layer
	o = 10;  			//number of neurons in output layer
	
	
	int n, m, p = 1; 		//temporary variables
	
	int correct_value, count_correct_value = 0;  
	int itterations = 10000;

	mnist_data *data;
	unsigned int cnt;
    int ret;

	if (ret = mnist_load("train-images.idx3-ubyte", "train-labels.idx1-ubyte", &data, &cnt))
    		printf("An error occured: %d\n", ret);

	double M_input[i], M_output[o], M_hidden_1[f],  M_hidden_2[s];
	double M_weight_1[f][i], M_weight_2[s][f], M_weight_3[o][s];
	double M_temp_1[i][f], M_temp_2[f][s], M_temp_3[s][o];
	double M_bias_1[f], M_bias_2[s], M_bias_3[o];

	
	//loading bias from txt file to weights matrix

	FILE *bias_file;
	bias_file = fopen("bias.txt", "r");							//accessing bias.txt file

	int stored_lines = 0;										//number of stored lines of bias.txt file

    double b = 0;
	
	int max_bias_width = 20;

	char btemp[max_bias_width];

	while (fgets(btemp, max_bias_width, bias_file))				//getting biases line by line (20 by 20 characters, i.e. 1 by 1 bias)
	{
        b = atof(btemp);										//atof converts array to double 
        if (b == 0)												//atof returns 0 if conversion failed
            continue;

		if(stored_lines < f)									//if the number of neurons in the first hidden layer is less than stored_lines
			M_bias_1[stored_lines] = b;							//then put the converted number to the first hidden layer bias

		if (stored_lines >= f && stored_lines < (f+s))			//else if the number of sum neurons in first and the second hidden layer is less than stored_lines
				M_bias_2[stored_lines - f] = b;					//then put the converted number to the second hidden layer bias

		if (stored_lines >= (f+s))								//else 
				M_bias_3[stored_lines - f - s] = b;				//put the converted number to the output layer bias

        stored_lines++;											//line succesfully stored
	}

	fclose(bias_file);

    //loading weights from txt file to weights matrix

    FILE *fw;
	fw = fopen("weights.txt", "r");

	int wline = 0, c1 = 0, c2 = 0;

    double w = 0;

	char wtemp[30];

	while (fgets(wtemp, 30, fw))
	{
        w = atof(wtemp);

        if (w == 0)
            continue;

        if(wline < (i*f)) // i * f = 784 * 16 = 12544
        {
            c1 = wline / i; // c1 = [0, 15]
            c2 = wline % i; // c2 = [0, 255]

            M_weight_1[c1][c2] = w;
        }

        if(wline >= (i*f) && wline < (i*f + f*s)) //12800
        {
            c1 = (wline - (i*f)) / f ; // c1 = [0, 16)
            c2 = (wline - (i*f)) % f; // c2 = [0, 16) 16x faster than c1
			
            M_weight_2[c1][c2] = w;
            
        }
		
        if(wline >= (i*f + f*s) && wline < (i*f + f*s + s*o)) //12960
        {
            c1 = (wline - (i*f + f*s)) / s; // c1 = [0, 10)
            c2 = (wline - (i*f + f*s)) % s;

            M_weight_3[c1][c2] = w;
			
        }
        if(wline >= (i*f + f*s + s*o))
            break;
        else
            wline++;
	}

	fclose(fw);

	for (p = 0; p < itterations; p++)
	{

	//loading data from mnist to input matrix

	for (n = 0; n < i; n++)
		M_input[n] = (data+p)->data[n/28][n%28];


	
	//value of neurons in first hidden layer is sum products of loaded input matrix and loaded weights

	for (m = 0; m < i; m++)
		for (n = 0; n < f; n++)		
			M_temp_1[m][n] = M_input[m] * M_weight_1[n][m]; 
							

	for (n = 0; n < f; n++)
		for (m = 0; m < i; m++)
			M_hidden_1[n] += M_temp_1[m][n];

	for (m = 0; m < f; m++)
			M_hidden_1[m] += M_bias_1[m];


	for (n = 0; n < f; n++)
		M_hidden_1[n] = 1.0/(1.0 + exp((-M_hidden_1[n]))); //sigmoid function approximation

	//value of neurons in second hidden layer is sum products of first hidden layer matrix and loaded weights between them

	for (m = 0; m < f; m++)
		for (n = 0; n < s; n++)
			M_temp_2[m][n] = M_hidden_1[m] * M_weight_2[n][m];


	for (n = 0; n < s; n++)
		for (m = 0; m < f; m++)
			M_hidden_2[n] += M_temp_2[m][n];


	for (m = 0; m < s; m++)
		M_hidden_2[m] += M_bias_2[m];


	for (n = 0; n < s; n++)
		M_hidden_2[n] = 1.0/(1.0 + exp((-M_hidden_2[n])));

	//value of neurons in output layer is sum products of second hidden layer matrix and loaded weights between them

	for (m = 0; m < s; m++)
			for (n = 0; n < o; n++)
				M_temp_3[m][n] = M_hidden_2[m] * M_weight_3[n][m];


	// output calculation


	for (n = 0; n < o; n++)
		for(m = 0; m < s; m++)
			M_output[n] += M_temp_3[m][n];

	for (m = 0; m < o; m++)
		M_output[m] += M_bias_3[m];


	for (n = 0; n < o; n++)
		M_output[n] = 1.0/(1.0 + exp((-M_output[n])));

	correct_value = checker((data+p)->label, M_output);

	if(correct_value==0)
		count_correct_value++;

	}
	
	printf("\n\nCorrect Percente: %f\n\n",((float)count_correct_value/(float)itterations)*100.0);

	return 0;
}


int checker(int index, double *output)
{
	int cnt;

	for(cnt = 1; cnt <= 10; cnt++)
	{
		if(cnt == index)
			continue;
		else
			if(output[cnt] >= output[index])
				return 1;
	}
	return 0;
}
