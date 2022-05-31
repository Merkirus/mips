#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

unsigned char first[] = {0x99,0x99,0xf0};
unsigned char second[] = {0x1f};

void dodBCD();

int main(int argc, char const *argv[])
{
	dodBCD();
	return 0;
}

void dodBCD()
{
	/*MIERZENIE DLUGOSCI*/
	int first_byte_size = 0;
	int second_byte_size = 0;
	int first_half_byte_size = 0;
	int second_half_byte_size = 0;

	while (1)
	{
		unsigned char lower_byte = first[first_byte_size] & 0x0f;
		unsigned char upper_byte = first[first_byte_size] & 0xf0;
		if (upper_byte >= 0xf0)
		{
			++first_byte_size;
			++first_half_byte_size;
			break;
		}
		if (lower_byte == 0x0f)
		{
			++first_byte_size;
			first_half_byte_size += 2;
			break;
		}
		++first_byte_size;
		first_half_byte_size += 2;
	}

	while (1)
	{
		unsigned char lower_byte = second[second_byte_size] & 0x0f;
		unsigned char upper_byte = second[second_byte_size] & 0xf0;
		if (upper_byte >= 0xf0)
		{
			++second_byte_size;
			++second_half_byte_size;
			break;
		}
		if (lower_byte == 0x0f)
		{
			++second_byte_size;
			second_half_byte_size += 2;
			break;
		}
		++second_byte_size;
		second_half_byte_size += 2;
	}

	/*KONIEC MIERZENIA*/

	/*DODAWANIE*/
	int half_byte_max_size = first_half_byte_size > second_half_byte_size
							? first_half_byte_size : second_half_byte_size;
	int half_byte_max_size_for_latter = half_byte_max_size;
	int max_size = first_byte_size > second_byte_size
						? first_byte_size : second_byte_size;
	int max_size_for_later = max_size;

	unsigned char result[max_size];

	int r;
	for (r=0; r < max_size; ++r)
		result[r] = 0;

	unsigned char carry_over = 0x00;

	if (half_byte_max_size%2 != 0)
		--max_size;

	for (--half_byte_max_size; half_byte_max_size > 0;)
	{
		unsigned char first_value = 0x00;
		unsigned char second_value = 0x00;

		while (first_half_byte_size > 0)
		{		
			if (first_half_byte_size%2 == 0)
			{
				first_value = first[first_byte_size-1] & 0x0f;
			}
			else
			{
				first_value = first[first_byte_size-1] & 0xf0;
				first_value >>= 4;
				--first_byte_size;
			}
			--first_half_byte_size;
			if (first_value != 0x0f)
				break;
			first_value = 0x00;
		}

		while (second_half_byte_size > 0)
		{
			if (second_half_byte_size%2 == 0)
			{
				second_value = second[second_byte_size-1] & 0x0f;
			}
			else
			{
				second_value = second[second_byte_size-1] & 0xf0;
				second_value >>= 4;
				--second_byte_size;
			}
			--second_half_byte_size;
			if (second_value != 0x0f)
				break;
			second_value = 0x00;
		}

		unsigned char sum = first_value + second_value + carry_over;
		carry_over = 0x00;

		if (sum > 0x09)
		{
			carry_over = 0x01;
			sum += 0x06;
			sum -= 0x10;
		}

		printf("SUMA %d\n", sum);

		if (half_byte_max_size%2 == 0)
		{
			result[max_size-1] = sum;
			--half_byte_max_size;
		}
		else
		{
			sum <<= 4;
			result[max_size-1] += sum ;
			--half_byte_max_size;
			--max_size;
		}

		printf("RESULT %d\n", result[max_size-1]);
	}

	/*PRZESUNIECIE W PRZYPADKU CARRY_OVER=1*/
	int i,x,y;
	if (carry_over != 0x00)
	{
		int carry_over_size = half_byte_max_size_for_latter%2 == 0
							? max_size_for_later+1 : max_size_for_later;
		unsigned char result2[carry_over_size];
		if (half_byte_max_size_for_latter%2 == 0)
		{
			unsigned char next = 0x00;
			for (i=carry_over_size-1; i > 0; --i)
			{
				unsigned char lower_byte = result[i-1] & 0x0f;
				unsigned char upper_byte = result[i-1] & 0xf0;
				upper_byte >>= 4;
				lower_byte <<= 4;
				result2[i] = lower_byte | next;
				next = upper_byte;
			}
			result2[0] = 0x10 | next;
		}
		else
		{
			unsigned char prev = 0x10;
			for (i=0; i < carry_over_size; ++i)
			{
				unsigned char lower_byte = result[i] & 0x0f;
				unsigned char upper_byte = result[i] & 0xf0;
				upper_byte >>= 4;
				result2[i] = prev | upper_byte;
				prev = lower_byte;
			}
		}

		if (half_byte_max_size_for_latter%2 != 0)
		{
			result2[carry_over_size-1] += 0x0f;
		}
		else
		{
			result2[carry_over_size-1] = 0xf0;
		}

		for (y=0; y < carry_over_size; ++y)
		{
			for (x=0; x < 8; ++x)
			{
				unsigned char output = (result2[y] >> (7-x)) & 1;
				if (x==4)
					printf(" ");
				printf("%d", output);
			}
			printf(" ");
		}
		return;
	}
	/*KONIEC PRZESUNIECIA*/

	/*0xF0 lub 0x0F na koncu*/
	if (half_byte_max_size_for_latter%2 != 0)
	{
		result[max_size_for_later-1] = 0xf0;
	}
	else
	{
		result[max_size_for_later-1] += 0x0f;
	}
	/*KONIEC*/

	for (y=0; y < max_size_for_later; ++y)
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