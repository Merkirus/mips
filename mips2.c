#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

unsigned char first[] = {0x32,0x1f};
unsigned char second[] = {0x01, 0x9f};

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
		if (upper_byte == 0xf0)
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
		if (upper_byte == 0xf0)
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

	/*Potencjalna wieksza tablicy w razie przeniesienia bitu*/
	int carry_over_size;

	if (first_byte_size > second_byte_size)
	{
		if (first_half_byte_size%2 != 0)
		{
			carry_over_size = first_byte_size+1;
		}
		else
		{
			carry_over_size = first_byte_size+2;
		}
	}
	else
	{
		if (second_half_byte_size%2 != 0)
		{
			carry_over_size = second_byte_size+1;
		}
		else
		{
			carry_over_size = second_byte_size+2;
		}
	}
	/*KONIEC*/

	/*DODAWANIE*/

	int max_size = first_byte_size > second_byte_size
						? first_byte_size : second_byte_size;
	int min_size = first_byte_size < second_byte_size
						? first_byte_size : second_byte_size;
	int max_size_for_later = max_size;

	unsigned char result[max_size];

	unsigned char carry_over = 0x00;

	for (; min_size>0; --first_byte_size, --second_byte_size, --min_size, --max_size)
	{
		unsigned char lower_first = first[first_byte_size-1] & 0x0f;
		unsigned char upper_first = first[first_byte_size-1] & 0xf0;
		upper_first >>= 4;
		if (upper_first == 0x0f)
		{
			lower_first = 0x00;
			upper_first = 0x00;
		}
		if (lower_first == 0x0f)
		{
			lower_first = 0x00;
		}

		unsigned char lower_second = second[second_byte_size-1] & 0x0f;
		unsigned char upper_second = second[second_byte_size-1] & 0xf0;
		upper_second >>= 4;

		if (upper_second == 0x0f)
		{
			lower_second = 0x00;
			upper_second = 0x00;
		}
		if (lower_second == 0x0f)
		{
			lower_second = 0x00;
		}

		unsigned char lower_sum = lower_first + lower_second + carry_over;
		printf("%d %s\n", lower_sum, "LOW");
		carry_over = 0x00;

		if (lower_sum > 0x09)
		{
			carry_over = 0x01;
			lower_sum += 0x06;
			lower_sum -= 0x10;
		}

		unsigned char upper_sum = upper_first + upper_second + carry_over;
		printf("%d %s\n", upper_sum, "HIGH");
		carry_over = 0x00;

		if (upper_sum > 0x09)
		{
			carry_over = 0x01;
			upper_sum += 0x06;
			upper_sum -= 0x10;
		}

		upper_sum <<= 4;

		result[max_size-1] = upper_sum | lower_sum;
	}
	/*KONIEC DODAWANIA*/

	/*DODAWANIE RESZTY WIEKSZEJ LICZBY*/

	while (first_byte_size > 0)
	{
		unsigned char lower_first = first[first_byte_size-1] & 0x0f;
		unsigned char upper_first = first[first_byte_size-1] & 0xf0;
		upper_first >>= 4;

		if (upper_first == 0x0f)
		{
			lower_first = 0x00;
			upper_first = 0x00;
		}
		if (lower_first == 0x0f)
		{
			lower_first = 0x00;
		}

		unsigned char lower_sum = lower_first + carry_over;
		carry_over = 0x00;

		if (lower_sum > 0x09)
		{
			carry_over = 0x01;
			lower_sum += 0x06;
			lower_sum -= 0x10;
		}

		unsigned char upper_sum = upper_first + carry_over;

		if (upper_sum > 0x09)
		{
			carry_over = 0x01;
			upper_sum += 0x06;
			upper_sum -= 0x10;
		}

		upper_sum <<= 4;

		result[first_byte_size-1] = upper_sum | lower_sum;
	}

	while (second_byte_size > 0)
	{
		unsigned char lower_second = second[second_byte_size-1] & 0x0f;
		unsigned char upper_second = second[second_byte_size-1] & 0xf0;
		upper_second >>= 4;

		if (upper_second == 0x0f)
		{
			lower_second = 0x00;
			upper_second = 0x00;
		}
		if (lower_second == 0x0f)
		{
			lower_second = 0x00;
		}

		unsigned char lower_sum = lower_second + carry_over;
		carry_over = 0x00;

		if (lower_sum > 0x09)
		{
			carry_over = 0x01;
			lower_sum += 0x06;
			lower_sum -= 0x10;
		}

		unsigned char upper_sum = upper_second + carry_over;

		if (upper_sum > 0x09)
		{
			carry_over = 0x01;
			upper_sum += 0x06;
			upper_sum -= 0x10;
		}

		upper_sum <<= 4;

		result[second_byte_size-1] = upper_sum | lower_sum;
	}

	/*PRZESUNIECIE W PRZYPADKU CARRY_OVER=1*/
	unsigned char result2[carry_over_size];
	int i,x,y;
	if (carry_over != 0x00)
	{
		if (first_byte_size > second_byte_size)
		{
			if (first_half_byte_size%2 != 0)
			{
				for (i=1; i <= max_size_for_later+1; ++i)
					result2[i] = result[i-1];
				result2[0] = carry_over;
			}
			else
			{
				unsigned char save = 0x10;
				for (i=1; i <= max_size_for_later+1; ++i)
				{
					unsigned char lower_byte = result[i] & 0x0f;
					unsigned char upper_byte = result[i] & 0xf0;
					upper_byte >>= 4;
					result2[i] = save | upper_byte;
					save = lower_byte;
				}
			}
		}
		else
		{
			if (second_half_byte_size%2 != 0)
			{
				for (i=1; i <= max_size_for_later+1; ++i)
					result2[i] = result[i-1];
				result2[0] = carry_over;
			}
			else
			{
				unsigned char save = 0x10;
				for (i=1; i <= max_size_for_later+1; ++i)
				{
					unsigned char lower_byte = result[i] & 0x0f;
					unsigned char upper_byte = result[i] & 0xf0;
					upper_byte >>= 4;
					result2[i] = save | upper_byte;
					save = lower_byte;
				}
			}
		}

		for (y=carry_over_size; y-- > 0; )
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

	/*KONIEC DODAWANIA RESZTY*/

	/*0xF0 lub 0x0F na koncu*/
	if (first_byte_size > second_byte_size)
	{
		if (first_half_byte_size%2 != 0)
		{
			result[max_size_for_later-1] = 0xf0;
		}
		else
		{
			result[max_size_for_later-1] += 0x0f;
		}
	}
	else
	{
		if (second_half_byte_size%2 != 0)
		{
			result[max_size_for_later-1] = 0xf0;
		}
		else
		{
			result[max_size_for_later-1] += 0x0f;
		}
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