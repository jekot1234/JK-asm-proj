// SobelFilterASM.cpp : Defines the exported functions for the DLL.
//

/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
 * przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów 
 * z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */

#include "pch.h"
#include "framework.h"
#include "SobelFilterCPP.h"
#include <math.h>

extern "C" SOBELFILTERCPP_API void fnSobelFilter(BYTE * data, BYTE * result, UINT64 start, UINT64 stop, UINT64 row_size) {

	//deklaracja masek
	int mask_G1[8] = { -1, 0, 1, -2, 2, -1, 0, 1 };
	int mask_G2[8] = { -2, -1, 0, -1, 1, 0, 1, 2 };
	int mask_G3[8] = { -1, -2, -1, 0, 0, 1, 2, 1 };
	int mask_G4[8] = { 0, -1, -2, 1, -1, 2, 1, 0 };

	//deklaracja matrycy adresów
	int addr_matrix[8] = { 0 };

	//deklaracja indeksu przetwarzanego piksela
	int curr_addr;

	//deklaracja zmiennych pomocniczych
	int pixel;
	int pixel_G1;
	int pixel_G2;
	int pixel_G3;
	int pixel_G4;

	//pêtla iteruj¹ca po wierszach
	for (int i = start; i < stop; i++) {
		//wyznaczenie adresu przetwarzanego wiersza
		curr_addr = i * row_size;
		//wyznaczenie matrycy adresów odpowiadaj¹cym s¹siednim pikselom
		addr_matrix[0] = curr_addr - row_size - 1;
		addr_matrix[1] = curr_addr - row_size;
		addr_matrix[2] = curr_addr - row_size + 1;
		addr_matrix[3] = curr_addr - 1;
		addr_matrix[4] = curr_addr + 1;
		addr_matrix[5] = curr_addr + row_size - 1;
		addr_matrix[6] = curr_addr + row_size;
		addr_matrix[7] = curr_addr + row_size + 1;

		//pêtla iteruj¹ca po pikselach w wierszu
		for (int j = 1; j < row_size - 1; j++) {

			//inkrementacja adresów
			curr_addr++;
			addr_matrix[0]++;
			addr_matrix[1]++;
			addr_matrix[2]++;
			addr_matrix[3]++;
			addr_matrix[4]++;
			addr_matrix[5]++;
			addr_matrix[6]++;
			addr_matrix[7]++;

			//obliczenie sumy wartoœci z mno¿enia pikseli razy maska G1
			pixel_G1 = mask_G1[0] * data[addr_matrix[0]] +
				mask_G1[1] * data[addr_matrix[1]] +
				mask_G1[2] * data[addr_matrix[2]] +
				mask_G1[3] * data[addr_matrix[3]] +
				mask_G1[4] * data[addr_matrix[4]] +
				mask_G1[5] * data[addr_matrix[5]] +
				mask_G1[6] * data[addr_matrix[6]] +
				mask_G1[7] * data[addr_matrix[7]];

			//obliczenie sumy wartoœci z mno¿enia pikseli razy maska G2
			pixel_G2 = mask_G2[0] * data[addr_matrix[0]] +
				mask_G2[1] * data[addr_matrix[1]] +
				mask_G2[2] * data[addr_matrix[2]] +
				mask_G2[3] * data[addr_matrix[3]] +
				mask_G2[4] * data[addr_matrix[4]] +
				mask_G2[5] * data[addr_matrix[5]] +
				mask_G2[6] * data[addr_matrix[6]] +
				mask_G2[7] * data[addr_matrix[7]];

			//obliczenie sumy wartoœci z mno¿enia pikseli razy maska G3
			pixel_G3 = mask_G3[0] * data[addr_matrix[0]] +
				mask_G3[1] * data[addr_matrix[1]] +
				mask_G3[2] * data[addr_matrix[2]] +
				mask_G3[3] * data[addr_matrix[3]] +
				mask_G3[4] * data[addr_matrix[4]] +
				mask_G3[5] * data[addr_matrix[5]] +
				mask_G3[6] * data[addr_matrix[6]] +
				mask_G3[7] * data[addr_matrix[7]];

			//obliczenie sumy wartoœci z mno¿enia pikseli razy maska G4
			pixel_G4 = mask_G4[0] * data[addr_matrix[0]] +
				mask_G4[1] * data[addr_matrix[1]] +
				mask_G4[2] * data[addr_matrix[2]] +
				mask_G4[3] * data[addr_matrix[3]] +
				mask_G4[4] * data[addr_matrix[4]] +
				mask_G4[5] * data[addr_matrix[5]] +
				mask_G4[6] * data[addr_matrix[6]] +
				mask_G4[7] * data[addr_matrix[7]];
			
			//obliczenie pierwiastka z sumy kwadratów zsumowanych wynikow mno¿enia
			pixel = sqrt(pixel_G1 * pixel_G1 + pixel_G2 * pixel_G2 + pixel_G3 * pixel_G3 + pixel_G4 * pixel_G4);

			//korekta wartoœci piksela
			if (pixel > 255)
				pixel = 255;
			else if (pixel < 0)
				pixel = 0;

			//zapisanie wyniku dla ka¿dego z kana³ów
			result[curr_addr * 3] = (BYTE)pixel;		//kana³ B
			result[curr_addr * 3 + 1] = (BYTE)pixel;	//kana³ G
			result[curr_addr * 3 + 2] = (BYTE)pixel;	//kana³ R

		}
	}
	return;
}
