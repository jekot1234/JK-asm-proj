/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania kraw�dzi w obrazie. Warto�� piksela wyznaczana jest na podstawie
 * przemno�enia masek z pikselami s�siaduj�cymi i obliczenie pierwiastka sumy kwadrat�w
 * z sumy wynik�w otrzymanych z mno�enia ka�dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#include "bitmap.h"
#include "gui.h"
#include <windows.h>
void execution(gui* user_interface);
UINT64 get_avaiable_memory();