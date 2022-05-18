#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

unsigned char first[] = {0x47};
unsigned char second[] = {0x23};

void dodBCD();

int main(int argc, char const *argv[])
{
	dodBCD();
	return 0;
}

void dodBCD()
{

	uint32_t i;
	uint32_t size_first = sizeof(first)/sizeof(first[0]);
	uint32_t size_second = sizeof(second)/sizeof(second[0]);

	uint32_t min_size = size_first < size_second ? size_first : size_second;
	uint32_t max_size = size_first < size_second ? size_second : size_first;

	uint32_t size_result = max_size;
	unsigned char result[max_size];

	unsigned char carry_over = 0x00;

	for (i=0; i < min_size; ++i)
	{
		unsigned char lower_first = first[i] & 0x0f;
		unsigned char upper_first = first[i] & 0xf0;
		upper_first >>= 4;
		unsigned char lower_second = second[i] & 0x0f;
		unsigned char upper_second = second[i] & 0xf0;
		upper_second >>= 4;
		
		unsigned char lower_sum = lower_first + lower_second + carry_over;
		carry_over = 0x00;

		if (lower_sum <= 0x09)
		{
			/*NIC*/
		}
		else if (lower_sum >= 0x10)
		{
			carry_over = 0x01;
			lower_sum += 0x06;
			lower_sum -= 0x10;
		}
		else /*III przypadek*/
		{
			carry_over = 0x01;
			lower_sum += 0x06;
			lower_sum -= 0x10;
		}
		unsigned char upper_sum = upper_first + upper_second + carry_over;
		carry_over = 0x00;

		if (upper_sum <= 0x09)
		{
			/*NIC*/
		}
		else if (upper_sum >= 0x10)
		{
			carry_over = 0x01;
			upper_sum -= 0x10;
			upper_sum += 0x06;
		}
		else /*III przypadek*/
		{
			carry_over = 0x01;
			upper_sum += 0x06;
		}
		upper_sum <<= 4;


		result[i] = upper_sum | lower_sum;
	}

	for (i=max_size-1; i >= min_size; --i)
	{	
		if (size_first > size_second)
		{
			unsigned char lower_first = first[i] & 0x0f;
			unsigned char upper_first = first[i] & 0xf0;
			upper_first >>= 4;
			
			unsigned char lower_sum = lower_first + carry_over;

			carry_over = 0x00;

			if (lower_sum <= 0x09)
			{
				/*NIC*/
			}
			else if (lower_sum >= 0x10)
			{
				carry_over = 0x01;
				lower_sum += 0x06;
				lower_sum -= 0x10;
			}
			else /*III przypadek*/
			{
				carry_over = 0x01;
				lower_sum += 0x06;
				lower_sum -= 0x10;
			}
			unsigned char upper_sum = upper_first + carry_over;

			carry_over = 0x00;

			if (upper_sum <= 0x09)
			{
				/*NIC*/
			}
			else if (upper_sum >= 0x10)
			{
				carry_over = 0x01;
				upper_sum -= 0x10;
				upper_sum += 0x06;
			}
			else /*III przypadek*/
			{
				carry_over = 0x01;
				upper_sum += 0x06;
			}
			upper_sum <<= 4;

			result[i] = upper_sum | lower_sum;
		}
		else
		{
			unsigned char lower_second = second[i] & 0x0f;
			unsigned char upper_second = second[i] & 0xf0;
			upper_second >>= 4;
			
			unsigned char lower_sum = lower_second + carry_over;
			carry_over = 0x00;

			if (lower_sum <= 0x09)
			{
				/*NIC*/
			}
			else if (lower_sum >= 0x10)
			{
				carry_over = 0x01;
				lower_sum += 0x06;
				lower_sum -= 0x10;
			}
			else /*III przypadek*/
			{
				carry_over = 0x01;
				lower_sum += 0x06;
				lower_sum -= 0x10;
			}
			unsigned char upper_sum = upper_second + carry_over;
			carry_over = 0x00;

			if (upper_sum <= 0x09)
			{
				/*NIC*/
			}
			else if (upper_sum >= 0x10)
			{
				carry_over = 0x01;
				upper_sum -= 0x10;
				upper_sum += 0x06;
			}
			else /*III przypadek*/
			{
				carry_over = 0x01;
				upper_sum += 0x06;
			}
			upper_sum <<= 4;

			result[i] = upper_sum | lower_sum;
		}
	}

	if (carry_over != 0x00)
	{
		char temp[size_result];
		char result2[size_result+1];
		uint32_t x;
		for (x=0; x < size_result; ++x)
			temp[x] = result[x];
		for (x=0; x < size_result; ++x)
			result2[x] = temp[x];
		result2[size_result] = carry_over;
		
		uint32_t y;
		for (y=0; y < size_result+1; ++y)
		{
			for (x=0; x < 8; ++x)
			{
				unsigned char output = (result[0] >> (7-x)) & 1;
				if (x==3)
					printf(" ");
				printf("%d", output);
			}
			printf(" ");
		}
		return;
	}

	printf("%d\n", size_result);

	uint32_t x, y;
	for (y=size_result; y-- > 0; )
	{
		for (x=0; x < 8; ++x)
		{
			unsigned char output = (result[y] >> (7-x)) & 1;
			if (x==4)
				printf(" ");
			printf("%d", output);
		}
		printf(" ");
	}
}