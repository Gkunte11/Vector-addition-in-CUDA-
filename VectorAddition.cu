#include<stdio.h>
#include<cuda.h>
#include<stdlib.h>
#include<time.h>


__global__ void addition(float *d_a, float *d_b, float *d_c, int n)
{
	
	// kernel function for calculating vector addition. blockIdx.x determines the block number, blockDim.x determines the number of threads per block and
	// threadIdx.x tells us the thread number in a particular block

	int i = blockIdx.x * blockDim.x + threadIdx.x;

	if(i < n)
	{
		d_c[i] = d_a[i] + d_b[i];
	}
}

int main()
{
	int n;
	printf("******* GPU Vector Addition *******\n");
	printf("Enter the total numbers: ");
	scanf("%d", &n);

	float *h_a, *h_b, *h_c;
	float *d_a, *d_b, *d_c;

	size_t bytes = n * sizeof(float);

	// dynamically allocating size to the device and host variables

	h_a = (float*)malloc(bytes);
	h_b = (float*)malloc(bytes);
	h_c = (float*)malloc(bytes);


	cudaMalloc((void **)&d_a, bytes);
	cudaMalloc((void **)&d_b, bytes);
	cudaMalloc((void **)&d_c, bytes);

	// accepting random elements for vectors h_a and h_b

	time_t t;
	srand((unsigned)time(&t));
	int x, y, flag;

	for (unsigned i = 0 ; i < n ; i++)
	{
		x = rand()%n;

		flag=0;
		for(int j=0;j<i;j++)
		{
			if(h_a[j]==x)
			{
				i--;
				flag=1;
				break;
			}
		}
		if(flag==0)
			h_a[i]=x;
	}

	for (unsigned i = 0 ; i < n ; i++)
	{
		y = rand()%n;

		flag=0;
		for(int j=0;j<i;j++)
		{
			if(h_b[j]==y)
			{
				i--;
				flag=1;
				break;
			}
		}
		if(flag==0)
			h_b[i]=y;
	}

	/*
	printf("\nThe vector A is: \n"); 
	for(int i = 0; i < n; i++)
	{
		printf("%f\n", h_a[i]);
		
	}

	printf("\n\nThe vector B is: \n"); 
	for(int i = 0; i < n; i++)
	{
		printf("%f\n", h_b[i]);
		
	}  
	*/

	// copying the host variables onto the device for addition	
	
	cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, h_b, bytes, cudaMemcpyHostToDevice);

	int number_of_threads_per_block = 256;

	int number_blocks = (int)ceil((float)n / number_of_threads_per_block);

	addition<<<number_blocks, number_of_threads_per_block>>>(d_a, d_b, d_c, n);

	// copying the final answer from the device to the host
	
	cudaMemcpy(h_c, d_c, bytes, cudaMemcpyDeviceToHost);

	printf("\n\nThe vector C after addition of A and B is: \n");
	for(int i = 0; i < n; i++)
	{
		printf("%f\n", h_c[i]);
	} 

	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);

	free(h_a);
	free(h_b);
	free(h_c);

	return 0;

}
