/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
 * przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów
 * z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#ifndef HISTOGRAM_H
#define HISTOGRAM_H

#include "bitmap.h"
class histogram : private bitmap {
	//tablice odpowiadajace ilosci pikseli o danej wartosci koloru
	long hist_tab_g[256] = { 0 };
	long hist_tab_b[256] = { 0 };
	long hist_tab_r[256] = { 0 };

	//normalizacja histogramu
	void normalize_hist();
	//rysowanie histogramu na otwartym pliku ze wzorem
	void draw_hist();
	//wyzanczecznie wspolzednych pierwszej kolumny do rysowania histogramu
	int col_to_start_coord(int col);
	//rysowanie kolumny
	void draw_col(int col);

public:
	histogram() = default;
	histogram(std::filesystem::path in_file_path, std::filesystem::path out_file_path) : bitmap(in_file_path, out_file_path) {};
	//zapisanie pliku z histogramem
	void save_histogram();
	//metoda uruchamiajace tworzenie histogramu
	void create_hist(bitmap* source);
};

//metoda wczytujaca wzorzec pod wygenerowanie histogramu
void createhistogram(bitmap* source);

#endif // !HISTOGRAM_H


