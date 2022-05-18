#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

uint32_t dodBCD(uint32_t,uint32_t);

int main(int argc, char const *argv[])
{
	
	return 0;
}

uint32_t dodBCD(uint32_t first, uint32_t second)
{
	int32_t first_exp = -1;
	uint32_t temp_first = first;
	while (temp_first!=0)
	{
		temp_first /= 10;
		++first_exp;
	}

	int32_t second_exp = -1;
	uint32_t temp_second = second;
	while (temp_second!=0)
	{
		temp_second /= 10;
		++second_exp;
	}

	uint32_t size_first = (first_exp/2)+(first_exp%2);
	uint32_t size_second = (second_exp/2)+(second_exp%2);

	char firstBCD[size_first];
	char secondBCD[size_second];

	int i, potega;
	for (i=0,potega=10; i < size_first; ++i, potega*=1000)
	{	
		if (i+1 == size_first && size_first%2 == 1)
		{
			uint32_t temp = 0xf;
			temp = temp << 4;
			firstBCD[i] = temp;
		} else
		{
			uint32_t temp = first % (10*potega);
			temp = temp << 4;
			firstBCD[i] = temp;
		}
		potega/=10;
		firstBCD[i] += first % (10*potega);
	}

	for (i=0,potega=10; i < size_second; ++i, potega*=1000)
	{
		if (i+1 == size_second && size_second%2 == 1)
		{
			uint32_t temp = 0xf;
			temp = temp << 4;
			secondBCD[i] = temp;
		} else
		{
			uint32_t temp = second % (10*potega);
			temp = temp << 4;
			secondBCD[i] = temp;
		}
		potega/=10;
		secondBCD[i] += second % (10*potega);
	}

	uint32_t lower_size;

	if (size_first > size_second)
		lower_size = size_first;
	else
		lower_size = size_second;

	for (i=0; i < lower_size; ++i)
	{
		
	}

	return 0;
}