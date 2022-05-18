#include <stdlib.h>
#include <stdio.h>

float convert(int32_t);

int main(int argc, char const *argv[])
{
	printf("%f",convert(12));
	return 0;
}

float convert(int32_t x)
{
	if (x == 0)						
		return 0;

	uint32_t output=0;		
	uint32_t input;	
	uint32_t exp = 0;
	uint32_t mantysa = 0;
	uint32_t znak = 0;

	if (x < 0)						
	{
		input = x * -1;				
		znak = 1;
		znak = znak << 31;
	} else {
		input = x;
		znak = 0;
	}

	uint32_t temp = input;

	int potega = -1;

	while (temp!=0) {
		temp = temp >> 1;
		++potega;
	}

	exp = 127 + potega;

	exp = exp << 23;

	uint32_t poprawka = 1;

	poprawka = poprawka << potega;	

	mantysa = input - poprawka;

	int przesuniecie = 22 - (potega-1);

	if (input > 0xffffff)
	{
		przesuniecie = przesuniecie * -1;
		mantysa = mantysa >> przesuniecie;
	} else {
		mantysa = mantysa << przesuniecie;
	}

	output = znak | exp | mantysa;

	return *(float*)&output;
}