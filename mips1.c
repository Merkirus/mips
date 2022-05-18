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

	/*Gdy jest minus, to robimy plus, ale pamietamy znak
	1 - w IEEE754 to minus, robimy to bo dodatni U2 to binarka*/
	if (x < 0)						
	{
		input = x * -1;				
		znak = 1;
		/*znak na indeksie 31 w IEEE754, wiec przesuwamy*/
		znak = znak << 31;
	} else {
		input = x;
		/*tu bez przesuniecia bo 0*/
		znak = 0;
	}

	uint32_t temp = input;

	int potega = -1;

	/*temp pozwala na sprawdzic potege, gdy po shiftach liczba
	bedzie rowna 0, to liczba shiftow byla potega dwojki*/
	while (temp!=0) {
		temp = temp >> 1;
		++potega;
	}

	/*exp dla potegi zero wyglada 0111|1111, co wychodzi po prostu
	na 127, od tego zaczynamy i dodajemy obliczone potegi*/

	exp = 127 + potega;

	/*wstawiamy na 23 gdzie jej miejsce w IEEE-754*/
	exp = exp << 23;

	/*poprawka sluzy usunieciu najbardziej znaczacego bitu,
	normalizacja mantysy*/

	uint32_t poprawka = 1;

	poprawka = poprawka << potega;	

	mantysa = input - poprawka;

	/*podsuwamy mantyse na poprawne bity z uwzglednieniem
	odcietego bitu*/
	int przesuniecie = 22 - (potega-1);

	/*if else dla przypadku gdy liczba jest wieksze niz 23 bity,
	wtedy tracimy najmniej znaczace bity, ale jeszcze zamiast
	w lewo przesuwamy w prawo*/
	if (input > 0xffffff)
	{
		przesuniecie = przesuniecie * -1;
		mantysa = mantysa >> przesuniecie;
	} else {
		mantysa = mantysa << przesuniecie;
	}

	/*bitowy or, pozwala na laczenie liczb, poniewaz wszystkie bity,
	poza wprowadzonymi sa zerami, to tylko te bity ktore wprowadzilismy
	beda przepisane i wszystko bedzie sie zgadzac*/
	output = znak | exp | mantysa;

	/*UWAGA: mega glupia rzecz, spedzilem nad tym godziny XD
	aby przepisac int na floata nie przez wartosc a przez jej zawartosc
	musisz przypisac worda (lw) do pointera na stacku, aby byla zachowana
	zawartosc, czyli do $sp, pozniej musisz lcw1 zaladowac tego pointera
	do floata, sam sie zderefrencjonuje i dostaniesz chcianego floata*/
	return *(float*)&output;
}