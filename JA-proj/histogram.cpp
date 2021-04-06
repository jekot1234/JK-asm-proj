/**
 * Projekt JA filtr Sobela
 * Algorytm do wyznaczania krawêdzi w obrazie. Wartoœæ piksela wyznaczana jest na podstawie
 * przemno¿enia masek z pikselami s¹siaduj¹cymi i obliczenie pierwiastka sumy kwadratów
 * z sumy wyników otrzymanych z mno¿enia ka¿dej maski.
 * 10.02.2021
 * @author Jeremi Kot, semestr V, SSI
 */
#include "histogram.h"
#include <QString>

void histogram::create_hist(bitmap* source) {
	int row;

	for (int i = 0; i < source->height; i++) {
		for (int j = 0; j < source->width * 3;) {

			row = i * source->row_size;

			this->hist_tab_b[(BYTE)(source->data[row + j])] += 1;
			j++;
			this->hist_tab_g[(BYTE)(source->data[row + j])] += 1;
			j++;
			this->hist_tab_r[(BYTE)(source->data[row + j])] += 1;
			j++;
		}
	}

	this->draw_hist();
}

void histogram::normalize_hist() {

	long max = hist_tab_b[0];
	for (int i = 1; i < 256; i++) {
		if (hist_tab_b[i] > max)
			max = hist_tab_b[i];
	}
	for (int i = 1; i < 256; i++) {
		if (hist_tab_g[i] > max)
			max = hist_tab_g[i];
	}
	for (int i = 1; i < 256; i++) {
		if (hist_tab_r[i] > max)
			max = hist_tab_r[i];
	}
	if (max != 0) {
		for (int i = 0; i < 256; i++) {
			hist_tab_b[i] = hist_tab_b[i] * 200 / max;
		}
	}
	if (max != 0) {
		for (int i = 0; i < 256; i++) {
			hist_tab_g[i] = hist_tab_g[i] * 200 / max;
		}
	}
	if (max != 0) {
		for (int i = 0; i < 256; i++) {
			hist_tab_r[i] = hist_tab_r[i] * 200 / max;
		}
	}

}

void histogram::draw_hist() {

	normalize_hist();

	for (int i = 0; i < 256; i++) {
		draw_col(i);
	}

}

void histogram::save_histogram() {
	out_file_stream->write((char*)data, filesize);
	out_file_stream->close();
}

inline int histogram::col_to_start_coord(int col) {
	int coord = (49 * row_size) + 20 * 3 + (col * 4 * 3);
	return coord;
}

void histogram::draw_col(int col) {

	int start_coord = col_to_start_coord(col);
	int coord = start_coord;

	for (int i = 0; i < hist_tab_b[col]; i++) {
		data[coord] = 255;
		coord += 3;
		data[coord] = 255;
		coord -= 3;
		coord += row_size;
	}
	coord = start_coord + 1;
	for (int i = 0; i < hist_tab_g[col]; i++) {
		data[coord] = 255;
		coord += 3;
		data[coord] = 255;
		coord -= 3;
		coord += row_size;
	}
	coord = start_coord + 2;
	for (int i = 0; i < hist_tab_r[col]; i++) {
		data[coord] = 255;
		coord += 3;
		data[coord] = 255;
		coord -= 3;
		coord += row_size;
	}
	return;
}

void createhistogram(bitmap* source) {
	std::filesystem::path hist_in = std::filesystem::path("histogram.bmp");

	std::u16string file_path = source->out_file_path.u16string();
	file_path.resize(file_path.size() - 4);
	QString tempU16 = QString("-histogram.bmp");
	file_path.append(tempU16.toStdU16String());
	std::filesystem::path hist_out(file_path);

	histogram hist = histogram(hist_in, hist_out);
	hist.create_hist(source);
	hist.save_histogram();
}
