#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>

unsigned char first[] = {0x22,0x5f};
unsigned char second[] = {0x22, 0xf0};

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

	/*DODAWANIE*/
	int half_byte_max_size = first_half_byte_size > second_half_byte_size
							? first_half_byte_size : second_half_byte_size;
	int max_size = first_byte_size > second_byte_size
						? first_byte_size : second_byte_size;
	int min_size = first_byte_size < second_byte_size
						? first_byte_size : second_byte_size;
	int max_size_for_later = max_size;

	unsigned char result[max_size];

	unsigned char carry_over = 0x00;

	if (half_byte_max_size%2 != 0)
		--max_size;

	for (--half_byte_max_size; max_size > 0;)
	{
		unsigned char first_value = 0x00;
		unsigned char second_value = 0x00;

		while (first_value != 0xf0 > first_byte_size > 0)
		{
			if (first_half_byte_size%2 == 0)
			{
				first_value = first[first_byte_size-1] & 0x0f;
				--first_half_byte_size;
			}
			else
			{
				first_value = first[first_byte_size-1] & 0xf0;
				first_value >>= 4;
				--first_half_byte_size;
				--first_byte_size;
			}
		}

		while (second_value != 0xf0 && second_byte_size > 0)
		{
			if (second_half_byte_size%2 == 0)
			{
				second_value = second[second_byte_size-1] & 0x0f;
				--second_half_byte_size;
			}
			else
			{
				second_value = second[second_byte_size-1] & 0xf0;
				second_value >>= 4;
				--second_half_byte_size;
				--second_byte_size;
			}
		}

		unsigned char sum = first_value + second_value + carry_over;
		carry_over = 0x00;

		if (sum > 0x09)
		{
			carry_over = 0x01;
			sum += 0x06;
			sum -= 0x10;
		}

		if (half_byte_max_size%2 == 0)
		{
			result[max_size-1] = sum;
			--half_byte_max_size;
		}
		else
		{
			result[max_size-1] += sum ;
			--half_byte_max_size;
			--max_size;
		}
	}

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
		printf("%s\n", "HERE");
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
		--first_byte_size;
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
		--second_byte_size;
	}

	/*PRZESUNIECIE W PRZYPADKU CARRY_OVER=1*/
	int max_half_byte_size = first_half_byte_size > second_half_byte_size
							? first_half_byte_size : second_half_byte_size;
	int i,x,y;
	if (carry_over != 0x00)
	{
		int carry_over_size = max_half_byte_size%2 == 0
							? max_size_for_later+1 : max_size_for_later;
		unsigned char result2[carry_over_size];
		if (max_half_byte_size%2 == 0)
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

		if (max_half_byte_size%2 != 0)
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

	/*KONIEC DODAWANIA RESZTY*/

	/*0xF0 lub 0x0F na koncu*/
	if (max_half_byte_size%2 != 0)
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