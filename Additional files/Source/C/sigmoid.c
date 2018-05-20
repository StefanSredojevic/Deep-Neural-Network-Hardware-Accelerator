#include <stdio.h>
#include <stdlib.h>
#include <math.h>
 
float sigmoid(float x, int beta);
//char* decimal_to_binary(int n,int size);

int main()
{
	float 	leftBoundary =  -16;//-2^<number of whole number bits> 2^4
	float 	rightBoundary = 16;//2^<number of whole number bits> 2^4
	int 	numOfSteps = 1024;//2^10 - Number of sampling dots, we are sending 10 bits like address
	float	step = (rightBoundary - leftBoundary) / numOfSteps;
	int beta = 1;
	float value = leftBoundary;
	float sigmoid_value = 0;
	int count = 0;
	FILE *f;
	
	printf("leftBoundary = %f \n",leftBoundary);
	printf("rightBoundary = %f \n",rightBoundary);
	printf("numOfSteps = %d \n",numOfSteps);
	
	f = fopen("sigmoid.txt","w");
	
	for(beta=1;beta<=1;beta++)
	{
		printf("**********************************\n");
		printf("BETA = %d \n",beta);
		printf("**********************************\n");
		
		value = leftBoundary;
		count = 0;
		
		while(count<numOfSteps)
		{
			sigmoid_value = sigmoid(value,beta);
				if(count==0)
				{
					fprintf(f,"**********************************\n");
					fprintf(f,"BETA = %d \n",beta);
					fprintf(f,"**********************************\n");
				}
			
			fprintf(f,"%.5f,",sigmoid_value);
			
			count++;
			value += step;
		}
	
	}
	
	fclose(f);
	
	return 0;
}

float sigmoid(float x,int beta)
{
     float exp_value;
     float return_value;
		
	 //if(x>=6.0)		//Removed in purpose of more accurate calculation
	 	//return 1.0;
		
     /*** Exponential calculation ***/
     exp_value = exp((double)-beta*x);

     /*** Final sigmoid value ***/
     return_value = 1 / (1 + exp_value);

     return return_value;
}
